//
//  Utils.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 24/08/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit
import CoreLocation

class Utils: NSObject {

	class func archievePath(fileName: String)->String {
		// Create a filepath for archiving.
		let  myPathList 	= NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let myPath			= myPathList[0] as NSString
		let path 			= myPath.stringByAppendingPathComponent(fileName)

		return path
	}

	class func humanReadableParkingLocation () -> String? {

		if let parkingLocation = Parking.sharedInstance.parkingLocation {

			if let
				address = parkingLocation.address,
				postCode = Parking.sharedInstance.parkingLocation?.postalcode,
				city = Parking.sharedInstance.parkingLocation?.city
				where(address.isEmpty == true) {
					return "\(postCode) \(city)"
			} else if let
				address = Parking.sharedInstance.parkingLocation?.address,
				streetNumber = Parking.sharedInstance.parkingLocation?.streetNumber,
				postCode = Parking.sharedInstance.parkingLocation?.postalcode,
				city = Parking.sharedInstance.parkingLocation?.city {
					return "\(address) \(streetNumber), \(postCode) \(city)"
			}
		}
		return nil
	}

	class func secondsToHoursMinutesSeconds (seconds : Double) -> (Double, Double, Double) {
		let (hr,  minf) = modf (seconds / 3600)
		let (min, secf) = modf (60 * minf)
		return (hr, min, 60 * secf)
	}
}
