//
//  Location.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 15/07/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit
import CoreLocation

class Location						: NSObject, NSCoding {

	var coordinates					: CLLocationCoordinate2D?
	var address						: String?
	var streetNumber				: String?
	var city						: String?
	var postalcode					: String?
	var descriptionOfTheLocation	: String?

	// MARK: Init

	init(locationCoordinates: CLLocationCoordinate2D, locationAddress: String, streetNumber: String, postalcode: String, city: String,  locationDescription: String) {

		self.coordinates 				= locationCoordinates
		self.address 					= locationAddress
		self.streetNumber 				= streetNumber
		self.city 						= city
		self.postalcode 				= postalcode
		self.descriptionOfTheLocation 	= locationDescription
	}

	// MARK: NSCoding

	required init?(coder decoder: NSCoder) {

		let latitude 					= decoder.decodeDoubleForKey(PKLLocationKeys.Latitude.rawValue)
		let longitude 					= decoder.decodeDoubleForKey(PKLLocationKeys.Longitude.rawValue)
		self.address 					= decoder.decodeObjectForKey(PKLLocationKeys.Address.rawValue) as? String
		self.streetNumber 				= decoder.decodeObjectForKey(PKLLocationKeys.StreetNumber.rawValue) as? String
		self.city 						= decoder.decodeObjectForKey(PKLLocationKeys.City.rawValue) as? String
		self.postalcode 				= decoder.decodeObjectForKey(PKLLocationKeys.Postalcode.rawValue) as? String
		self.descriptionOfTheLocation 	= decoder.decodeObjectForKey(PKLLocationKeys.DescriptionOfTheLocation.rawValue) as? String
		self.coordinates 				= CLLocationCoordinate2DMake(latitude, longitude)
	}

	func encodeWithCoder(encoder: NSCoder) {


		if let
			latitude 	= self.coordinates?.latitude,
			longitude	= self.coordinates?.longitude {
				encoder.encodeDouble(latitude, forKey: PKLLocationKeys.Latitude.rawValue)
				encoder.encodeDouble(longitude, forKey: PKLLocationKeys.Longitude.rawValue)
		}

		encoder.encodeObject(self.address, forKey: PKLLocationKeys.Address.rawValue)
		encoder.encodeObject(self.streetNumber, forKey: PKLLocationKeys.StreetNumber.rawValue)
		encoder.encodeObject(self.city, forKey: PKLLocationKeys.City.rawValue)
		encoder.encodeObject(self.postalcode, forKey: PKLLocationKeys.Postalcode.rawValue)
		encoder.encodeObject(self.descriptionOfTheLocation, forKey: PKLLocationKeys.DescriptionOfTheLocation.rawValue)

	}

	func reset() {

		self.coordinates 				= nil
		self.address 					= nil
		self.streetNumber 				= nil
		self.city 						= nil
		self.postalcode 				= nil
		self.descriptionOfTheLocation 	= nil
	}
}
