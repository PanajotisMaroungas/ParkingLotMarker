//
//  ServerCommunication.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 20/08/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit
import CoreLocation

private var _singletonInstanceServerCommunication = ServerCommunication()

class ServerCommunication: NSObject {
   
    class var sharedInstance: ServerCommunication {
        return _singletonInstanceServerCommunication
    }

    
    func postParkedLocation(location: Location){
        var dict: Dictionary<String, AnyObject>
        dict = ["type": "insert_new_parking", "latitude": (location.coordinates?.latitude)!, "longitude": location.coordinates!.longitude, "adress": location.address!, "streetNumber": location.streetNumber!, "postalcode": location.postalcode!, "city": location.city!, "startingTime": "2112-12-12 12:12:12", "endingTime": "2112-12-12 12:12:12" ]
        Communication.sharedInstance.sendToServer(dict, completionHandler: { (json, error) -> Void in
            if error == nil {
                print("json: \(json)")
            }else{
                print("Something went wrong with \"insert_new_parking\"")
            }
        })
    }

}
