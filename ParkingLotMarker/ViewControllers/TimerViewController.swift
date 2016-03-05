//
//  TimerViewController.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 24/08/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit
import MapKit

class TimerViewController						: UIViewController {

    @IBOutlet private weak var mapView			: MKMapView?
    @IBOutlet private weak var datePicker		: UIDatePicker?
    @IBOutlet private weak var viewForTip		: UIView?
    @IBOutlet private weak var textForTip		: UITextView?
    @IBOutlet private weak var imageTip			: UIImageView?
    @IBOutlet private weak var timerSwitcher	: UISwitch?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewRegion 		= MKCoordinateRegionMakeWithDistance(Parking.sharedInstance.parkingLocation!.coordinates!, 500, 500);
        let adjustedRegion 	= self.mapView?.regionThatFits(viewRegion)
        self.mapView?.setRegion(adjustedRegion!, animated: true)
        self.mapView?.showsUserLocation = true;

        self.mapView?.userInteractionEnabled = false
        self.datePicker?.backgroundColor = UIColor.whiteColor()
        self.viewForTip?.alpha = 0
        self.textForTip?.alpha = 0
        self.imageTip?.alpha = 0
        

        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = NSDateComponents()
        components.setValue(0, forComponent: NSCalendarUnit.Minute)
        components.setValue(1, forComponent: NSCalendarUnit.Hour)
        let defaultValue = calendar?.dateFromComponents(components)
        self.datePicker?.setDate(defaultValue!, animated: true)
        
        self.navigationItem.title = "Timer"
    }

	private func showTimer(hidden : Bool) {
		UIView.animateWithDuration(1, animations: { () in
			self.datePicker?.alpha 	= hidden ? 1 : 0
			self.viewForTip?.alpha 	= hidden ? 0 : 1
			self.textForTip?.alpha 	= hidden ? 0 : 1
			self.imageTip?.alpha 	= hidden ? 0 : 1
		})
	}

    @IBAction func switchPressed(sender: AnyObject) {

        if let _timerSwitcher = self.timerSwitcher {
			self.datePicker?.userInteractionEnabled = _timerSwitcher.on
			self.showTimer(_timerSwitcher.on)
		}

    }
    
    @IBAction func continueButtonPressed(sender: AnyObject) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        let startingTimeAsNSDate = NSDate()
        let startingTime = dateFormatter.stringFromDate(startingTimeAsNSDate)
        
        Parking.sharedInstance.parkingTime = startingTime
        
        if let _timerSwitcher = self.timerSwitcher where(_timerSwitcher.on == true) {
            
            let time = NSCalendar.currentCalendar().components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: (self.datePicker?.date)!)
            
            let parkingTimeAsTimeInterval = Double(time.minute*60+time.hour*60*60)
            let leavingTimeAsDate = startingTimeAsNSDate.dateByAddingTimeInterval(parkingTimeAsTimeInterval)
            
            Parking.sharedInstance.parkingLeavingTime = dateFormatter.stringFromDate(leavingTimeAsDate)
        }
		Parking.sharedInstance.parkingActive = true
        Parking.sharedInstance.persistParking()
    }

}
