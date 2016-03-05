//
//  ParkingLotMainScreen.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 12/07/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ParkingLotMainScreen: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    // MARK: - Outlets
    @IBOutlet private weak var mapView				: MKMapView?
	@IBOutlet private weak var axeX					: UIView?
	@IBOutlet private weak var axeY					: UIView?
	@IBOutlet private weak var buttonMarkThePlace	: UIButton?
	@IBOutlet private weak var modeSelector			: UISegmentedControl?
	@IBOutlet private weak var labelAddress			: UILabel?
	@IBOutlet private weak var loadingIndicator		: UIActivityIndicatorView?

	// MARK: - Properties

    var locationManager 			= CLLocationManager()

	var positionOfTheUser			:CLLocationCoordinate2D?
	var originalRegionForZooming	: MKCoordinateRegion?
    var currentLocation				: Location?

	var isLocationSetted 			= false
	var mustToCenter 				= false
	var initializedPosition 		= false
    var isInitialized 				= false {
        didSet {
			self.buttonMarkThePlace?.enabled = self.isInitialized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

		self.setUpUI()
		self.setUpLocationManager()

    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)


		if (Parking.sharedInstance.parkingActive == true) {

			print(Parking.sharedInstance.parkingLocation?.coordinates?.latitude)
			print(Parking.sharedInstance.parkingLocation?.coordinates?.longitude)

			self.performSegueWithIdentifier("showParking", sender: self)
		}
	}

    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
		if let _positionOfTheUser = (locations.last)?.coordinate {

				if (self.isLocationSetted == false) {
					self.buttonMarkThePlace?.enabled = true
					self.isLocationSetted = true
					let mapCamera = MKMapCamera(lookingAtCenterCoordinate: _positionOfTheUser, fromEyeCoordinate: _positionOfTheUser, eyeAltitude: 300)
					self.mapView?.setCamera(mapCamera, animated: false)
				}
				self.positionOfTheUser = _positionOfTheUser
		}
    }


    func locationManager(_manager: CLLocationManager,didChangeAuthorizationStatus status: CLAuthorizationStatus){

        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            print("AuthorizedAlways or AuthorizedWhenInUse")
            self.locationManager.startUpdatingLocation()
        case .Restricted:
            print("Restricted")
        case .Denied:
            print("Denied")
        case .NotDetermined:
            if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                self.locationManager.requestWhenInUseAuthorization()
            }
            print("NotDetermined")
        }
    }
    

    // MARK: Actions
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        
        switch self.modeSelector!.selectedSegmentIndex{
        case 0:
            print("Manually:LC")
            self.mapView!.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
            self.mapView!.scrollEnabled = true

        case 1:
            print("Find me:LC")
            self.mustToCenter = true
            self.mapView!.setUserTrackingMode(MKUserTrackingMode.None, animated: false)
            self.mapView!.scrollEnabled = true

			if let
				_positionOfTheUser = self.positionOfTheUser,
				_mapView = self.mapView
				where(self.mustToCenter) {
					let region = MKCoordinateRegionMake(_positionOfTheUser, _mapView.region.span)
					self.mapView?.setRegion(region, animated: true)
					self.mustToCenter = false
			}

			self.modeSelector?.selectedSegmentIndex = 0

		case 2:
            print("Follow me:LC")
            self.mapView?.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            self.mapView?.scrollEnabled = false

			if let
				_positionOfTheUser = self.positionOfTheUser,
				_mapView = self.mapView {
					let region = MKCoordinateRegionMake(_positionOfTheUser, _mapView.region.span)
					self.mapView?.setRegion(region, animated: true)
			}
        default:
            print("Unknown segment")
        }

    }


    @IBAction func zoomInAndOut(sender: AnyObject) {

        let recognizer = sender as? UIPinchGestureRecognizer
        
        if (recognizer?.state == UIGestureRecognizerState.Began) {
            self.originalRegionForZooming = self.mapView?.region;
        }

		if let _originalRegionForZoomimg = self.originalRegionForZooming {

			var latdelta = Double(_originalRegionForZoomimg.span.latitudeDelta) / Double(recognizer?.scale ?? 0)
			var londelta = Double(_originalRegionForZoomimg.span.longitudeDelta) / Double(recognizer?.scale ?? 0)

			latdelta = min(latdelta, 100)
			londelta = min(londelta, 100)

			let span = MKCoordinateSpanMake(latdelta, londelta);
			self.mapView?.setRegion(MKCoordinateRegionMake(_originalRegionForZoomimg.center, span), animated: false)
		}
    }

    @IBAction func markPlacePressed(sender: AnyObject) {
        Parking.sharedInstance.persistParking()
    }


    private func giveInformationForLocation(location: CLLocation) {

        self.loadingIndicator!.startAnimating()
        self.loadingIndicator!.hidden = false

        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                 if placemarks?.count > 0 {

					let placeMark = placemarks?.last

					var locationAddress		: String?
					var streetNumber		: String?
					var postalcode			: String?
					var city				: String?
					var locationDescription	: String?

					if let _thoroughfare = placeMark?.thoroughfare where(_thoroughfare.isEmpty == false) {
						locationAddress = _thoroughfare
					}

					if let _subThoroughfare = placeMark?.subThoroughfare where(_subThoroughfare.isEmpty == false) {
						streetNumber = _subThoroughfare
					}

					if let _postalCode = placeMark?.postalCode where(_postalCode.isEmpty == false) {
						postalcode = _postalCode
					}

					if let _subAdministrativeArea = placeMark?.subAdministrativeArea where(_subAdministrativeArea.isEmpty == false) {
						city = _subAdministrativeArea
					}

					if let _locality = placeMark?.locality where(_locality.isEmpty == false) {
						locationDescription = _locality
					}

					self.currentLocation = Location(locationCoordinates: location.coordinate, locationAddress: locationAddress ?? "", streetNumber: streetNumber ?? "", postalcode: postalcode ?? "", city: city ?? "", locationDescription: locationDescription ?? "")

					Parking.sharedInstance.parkingLocation = self.currentLocation ?? nil

					// TODO: imporove label
					self.labelAddress?.text = Utils.humanReadableParkingLocation()
					self.loadingIndicator?.stopAnimating()
					self.loadingIndicator?.hidden = true
					self.isInitialized = true
				}

        })
    }
}

// MARK: - Setup functions

extension ParkingLotMainScreen {

	private func setUpLocationManager() {
		self.locationManager.delegate 			= self
		self.locationManager.desiredAccuracy 	= kCLLocationAccuracyHundredMeters

		self.locationManager.requestAlwaysAuthorization()
	}

	private func setUpUI() {
		self.labelAddress?.adjustsFontSizeToFitWidth 	= true
		self.buttonMarkThePlace?.enabled 				= false
		self.loadingIndicator?.startAnimating()
	}
}

// MARK: - MapViewDelegate

extension ParkingLotMainScreen {

	func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {


		if let
			latitude = self.mapView?.region.center.latitude,
			longitude = self.mapView?.region.center.longitude {
				let location = CLLocation(latitude: latitude, longitude: longitude)



				let normalizedLat = self.normalizeLatitudeOrLongitude(self.currentLocation?.coordinates?.latitude ?? 0)
				let normalizedLon = self.normalizeLatitudeOrLongitude(self.currentLocation?.coordinates?.longitude ?? 0)
				let normalizedMapLat = self.normalizeLatitudeOrLongitude(latitude)
				let normalizedMapLon = self.normalizeLatitudeOrLongitude(longitude)

				if (normalizedLat != normalizedMapLat || normalizedLon != normalizedMapLon) {
					self.giveInformationForLocation(location)
				}
		}
	}
}

// MARK: - Private Functions

extension ParkingLotMainScreen {

	private func normalizeLatitudeOrLongitude(latOrLongDouble: Double) -> Double {
		return Double(Int(latOrLongDouble * 1000000))/1000000
	}

}
