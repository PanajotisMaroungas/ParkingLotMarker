//
//  Parking.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 24/08/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit
import CoreLocation

private var _singletonInstanceBooking = Parking()

class Parking				: NSObject, NSCoding {
    
    class var sharedInstance: Parking {
        return _singletonInstanceBooking
    }
    
    var parkingLocation		: Location?
    var parkingTime			: String?
    var parkingLeavingTime	: String?
    
    override init() {
        
        let path 	= Utils.archievePath(PLKFileName.Parking.rawValue)

		if let
			unarchivedParking:Parking = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Parking
			where(NSFileManager.defaultManager().fileExistsAtPath(path)) {

				self.parkingLocation 	= unarchivedParking.parkingLocation
				self.parkingTime 		= unarchivedParking.parkingTime
				self.parkingLeavingTime = unarchivedParking.parkingLeavingTime
		}
	}

    required init?(coder decoder: NSCoder) {
        self.parkingLocation 		= decoder.decodeObjectForKey(PKLParkingKeys.ParkingLocation.rawValue) as? Location
        self.parkingTime 			= decoder.decodeObjectForKey(PKLParkingKeys.ParkingTime.rawValue) as? String
        self.parkingLeavingTime 	= decoder.decodeObjectForKey(PKLParkingKeys.ParkingLeavingTime.rawValue) as? String
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.parkingLocation, forKey: PKLParkingKeys.ParkingLocation.rawValue)
        encoder.encodeObject(self.parkingTime, forKey: PKLParkingKeys.ParkingTime.rawValue)
        encoder.encodeObject(self.parkingLeavingTime, forKey: PKLParkingKeys.ParkingLeavingTime.rawValue)
    }
    
    func persistParking(){
        let path = Utils.archievePath(PLKFileName.Parking.rawValue)
        if NSKeyedArchiver.archiveRootObject(self, toFile: path) {
            print("Success writing to file  \(path)")
        } else {
            print("Unable to write to file \(path)")
        }
    }
}
