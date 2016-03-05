//
//  ParkingOverViewViewController.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 29/08/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ParkingOverViewViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet private weak var labelAddress			: UILabel?
    @IBOutlet private weak var labelDistanceInM		: UILabel?
    @IBOutlet private weak var labelDistanceInMin	: UILabel?
    @IBOutlet private weak var labelRemainingTime	: UILabel?
    @IBOutlet private weak var mapView				: MKMapView?
    
    var locationManager 					= CLLocationManager()
    var route								: MKRoute?
    var originalRegionForZooming			: MKCoordinateRegion?
    var timer								: NSTimer?
    var currentDistanceInHours				: Int?
    var currentDistanceInMinutes			: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)

		self.navigationItem.hidesBackButton = true
		self.navigationController?.navigationItem.leftBarButtonItem = nil

		self.navigationController?.navigationItem.backBarButtonItem = nil

		self.mapView?.delegate = self
        self.labelAddress?.adjustsFontSizeToFitWidth = true
        self.labelAddress?.text = Utils.humanReadableParkingLocation()
        self.updateTimerLabel()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView?.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        let parkingAnnotation = MKPointAnnotation()
        parkingAnnotation.coordinate = (Parking.sharedInstance.parkingLocation?.coordinates) ?? CLLocationCoordinate2D.init()
        parkingAnnotation.title = "Parking Plot"
        self.mapView?.addAnnotation(parkingAnnotation)

    }

    override func viewWillAppear(animated: Bool) {
        // countdown timer
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateTimerLabel"), userInfo: nil, repeats: true)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        self.timer?.invalidate()
    }
    
    func updateTimerLabel(){

        if Parking.sharedInstance.parkingLeavingTime != nil {
            let dateFormatter 				= NSDateFormatter()
            dateFormatter.dateFormat 		= DATE_FORMAT
            let parkingLeavingTimeAsDate 	= dateFormatter.dateFromString(Parking.sharedInstance.parkingLeavingTime!)
            let gregorian 					= NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            let components 					= gregorian?.components ([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: NSDate(), toDate: parkingLeavingTimeAsDate ?? NSDate(), options: NSCalendarOptions())
            let countdownTime 				= String(format: "%02d:%02d:%02d", components!.hour, components!.minute, components!.second)
            if (self.currentDistanceInHours > components?.hour) || (self.currentDistanceInMinutes > components?.hour && self.currentDistanceInMinutes > components?.minute){
                self.labelRemainingTime?.textColor = UIColor.redColor()
            } else {
                self.labelRemainingTime?.textColor = UIColor.greenColor()
            }
            if components?.hour >= 0 && components?.minute >= 0 && components?.second >= 0 {
                self.labelRemainingTime?.text = countdownTime
            } else {
                let countdownTime 				= String(format: "%02d:%02d:%02d", -components!.hour, -components!.minute, -components!.second)
				self.labelRemainingTime?.text = "Time elapsed -(" + countdownTime + ")"
            }
        } else {
            self.labelRemainingTime?.text = "-"

        }
    }
    
    // MARK: MapView Delegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let myLineRenderer = MKPolylineRenderer(polyline: self.route!.polyline)
        myLineRenderer.strokeColor = UIColor.redColor()
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let directionsRequest 			= MKDirectionsRequest()

		if let coordinates = Parking.sharedInstance.parkingLocation?.coordinates,
			currentLocation = locations.last {

			let parkingPlaceAsPlaceMark 	= MKPlacemark(coordinate: coordinates, addressDictionary: nil)

			let currentPlaceAsPlaceMark 	= MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
			directionsRequest.source 		= MKMapItem(placemark: parkingPlaceAsPlaceMark)
			directionsRequest.destination 	= MKMapItem(placemark: currentPlaceAsPlaceMark)
			directionsRequest.transportType = MKDirectionsTransportType.Walking
			let directions 					= MKDirections(request: directionsRequest)

			directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
				if error == nil && response!.routes.count > 0 {
					self.mapView?.removeOverlays(self.mapView!.overlays)
					self.route = response!.routes[0]
					for step in response!.routes {
						self.mapView?.addOverlay(step.polyline)

					}
					self.mapView?.addOverlay((self.route?.polyline)!)
					let distanceInMetersAsString = String(format: "%.0f meters", self.route!.distance)
					self.labelDistanceInM?.text = distanceInMetersAsString
					let timeInSeconds = Int((self.route?.expectedTravelTime)!)
					let minAsInt = Int(timeInSeconds/60)

					if minAsInt > 60 {
						let hourAsInt = Int(minAsInt/60)
						self.labelDistanceInMin?.text = String(hourAsInt) + " hour " + String(minAsInt%60) + " min"
						self.currentDistanceInHours = hourAsInt
						self.currentDistanceInMinutes = minAsInt%60
					} else {
						self.labelDistanceInMin?.text = String(minAsInt) + " min"
						self.currentDistanceInHours = 0
						self.currentDistanceInMinutes = minAsInt%60
					}
				}
			}
		}
	}

    // MARK: Actions

    @IBAction func zoomInAndOut(sender: AnyObject) {

     	let recognizer = sender as! UIPinchGestureRecognizer
        if (recognizer.state == UIGestureRecognizerState.Began) {
            self.originalRegionForZooming = self.mapView?.region;
        }
        var latdelta = Double(self.originalRegionForZooming!.span.latitudeDelta) / Double(recognizer.scale)
        var londelta = Double(self.originalRegionForZooming!.span.longitudeDelta) / Double(recognizer.scale)
        
        latdelta = max(min(latdelta, 30), 0.001)
        londelta = max(min(londelta, 30), 0.001)
        
        let span = MKCoordinateSpanMake(latdelta, londelta);
        self.mapView?.setRegion(MKCoordinateRegionMake(self.originalRegionForZooming!.center, span), animated: false)
    
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {

        let alertController = UIAlertController(title: "PLM", message: "Do you really want to cancel the Parking?", preferredStyle: UIAlertControllerStyle.Alert)
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in}
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
            self.locationManager.stopUpdatingLocation()
            self.timer?.invalidate()
			Parking.sharedInstance.reset()
            Parking.sharedInstance.parkingTime = nil
            Parking.sharedInstance.parkingLeavingTime = nil
            Parking.sharedInstance.parkingLocation?.reset()
            Parking.sharedInstance.persistParking()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true){}
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    // MARK: Notifications
    
    func applicationDidEnterBackground() {
        // setting local notifications
        self.setLocalNotification(0.5)
        self.setLocalNotification(0.75)
        self.setLocalNotification(0.9)
        self.locationManager.stopUpdatingLocation()
        self.timer?.invalidate()
    }
    
    func applicationDidBecomeActive() {
        self.locationManager.startUpdatingLocation()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateTimerLabel"), userInfo: nil, repeats: true)

    }
    
    // MARK: - Private functions
    
    private func setLocalNotification(percentageScale: Double ){
        if Parking.sharedInstance.parkingLeavingTime == "" || Parking.sharedInstance.parkingLeavingTime == nil {
			return
        }

        let localNotification = UILocalNotification()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT

        let parkingTimeAsDate = dateFormatter.dateFromString(Parking.sharedInstance.parkingTime!)
        let parkingLeavingTimeAsDate = dateFormatter.dateFromString(Parking.sharedInstance.parkingLeavingTime!)!
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = gregorian?.components ([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: parkingTimeAsDate!, toDate: parkingLeavingTimeAsDate, options: NSCalendarOptions())
        let halfTimeInterval = Double(components!.hour*60*60 + components!.minute*60 + components!.second)*percentageScale
        let parkingminutes: Double = Double(components!.hour*60 + components!.minute)
        let minutesAsDouble: Int = Int(parkingminutes-parkingminutes*percentageScale)
        localNotification.alertBody = LOCAL_NOTIFICATION_TITLE_A + String(stringInterpolationSegment: minutesAsDouble) + LOCAL_NOTIFICATION_TITLE_B

        let notificationTime = NSDate(timeInterval: halfTimeInterval, sinceDate: parkingTimeAsDate!)

        if (notificationTime.compare(NSDate()) == NSComparisonResult.OrderedDescending) {
            localNotification.fireDate = notificationTime
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber+1;
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)

        }

    }
}
