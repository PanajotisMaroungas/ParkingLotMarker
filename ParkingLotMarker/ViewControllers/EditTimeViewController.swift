//
//  EditTimeViewController.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 01/09/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit

class EditTimeViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelCurrentTime: UILabel!
    @IBOutlet weak var labelNewTime: UILabel!
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = NSDateComponents()
        components.setValue(0, forComponent: NSCalendarUnit.Minute)
        components.setValue(1, forComponent: NSCalendarUnit.Hour)
        let defaultValue = calendar?.dateFromComponents(components)
        self.datePicker.setDate(defaultValue!, animated: true)

        // countdown timer
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateTimerLabel"), userInfo: nil, repeats: true)
        
        self.labelNewTime.text = "1 hour 0 minutes"
    }

    func updateTimerLabel(){
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        
        
        if let parkingLeavingT = Parking.sharedInstance.parkingLeavingTime {

            let parkingLeavingTimeAsDate = dateFormatter.dateFromString(parkingLeavingT)
            
            let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            
            let components = gregorian?.components ([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: NSDate(), toDate: parkingLeavingTimeAsDate!, options: NSCalendarOptions())
            
            let countdownTime = String(format: "%02d:%02d:%02d", components!.hour, components!.minute, components!.second)
            
            if components?.hour >= 0 && components?.minute >= 0 && components?.second >= 0 {
                self.labelCurrentTime.text = countdownTime
                
            }else{
                self.timer?.invalidate()
            }
        }else{
            self.timer?.invalidate()
            self.labelCurrentTime.text = "N/A"
        }
    }

    
    @IBAction func datePickerValueChanged(sender: AnyObject) {
                
        let dateFromDatePicker = self.datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        let components = gregorian?.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: dateFromDatePicker)
        
        self.labelNewTime.text = "\(components!.hour) hour \(components!.minute) minutes"
    }
    
    // MARK: Actions

    
    @IBAction func saveButtonPressed(sender: AnyObject) {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        let startingTimeAsNSDate = NSDate()
        let startingTime = dateFormatter.stringFromDate(startingTimeAsNSDate)
        
        Parking.sharedInstance.parkingTime = startingTime
        
        let time = NSCalendar.currentCalendar().components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: self.datePicker.date)
        
        let parkingTimeAsTimeInterval = Double(time.minute*60+time.hour*60*60)
        let leavingTimeAsDate = startingTimeAsNSDate.dateByAddingTimeInterval(parkingTimeAsTimeInterval)
        
        Parking.sharedInstance.parkingLeavingTime = dateFormatter.stringFromDate(leavingTimeAsDate)
        
        self.navigationController?.popViewControllerAnimated(true)
        Parking.sharedInstance.persistParking()
    }
}
