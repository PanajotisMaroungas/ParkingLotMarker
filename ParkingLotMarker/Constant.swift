//
//  Constant.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 20/08/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import Foundation

let URL 								= "http://localhost:8080/Webserver/rest/ParkingLotMarker/jsonServer"
let MESSAGE_TYPE_FOR_NEW_PARKING 		= "insert_new_parking"

let DATE_FORMAT 						= "yyyy-MM-dd HH:mm:ss"

let LOCAL_NOTIFICATION_TITLE_A 			= "FYI: "
let LOCAL_NOTIFICATION_TITLE_B 			= " minutes remaining. "

enum PLKFileName 						: String {
	case Parking						= "Parking.archive"
}

enum PKLParkingKeys 					: String {
	case ParkingLocation				= "parkingLocation"
	case ParkingTime					= "parkingTime"
	case ParkingLeavingTime				= "parkingLeavingTime"
	case ParkingActive					= "parkingActive"
}

enum PKLLocationKeys					: String {
	case Coordinates					= "coordinates"
	case Latitude						= "latitude"
	case Longitude						= "longitude"
	case Address						= "address"
	case StreetNumber					= "streetNumber"
	case City							= "city"
	case Postalcode						= "postalCode"
	case DescriptionOfTheLocation		= "descriptionOfTheLocation"
}

enum PKLUIStoryboardIdentifier			: String {
	case ParkingOverViewViewController	= "ParkingOverViewViewController"
}