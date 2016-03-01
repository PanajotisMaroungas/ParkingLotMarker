//
//  AppDelegate.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 12/07/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        Parking.sharedInstance.persistParking();
    }

    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
}


