//
//  PLKNavigationViewController.swift
//  parkinglotmarker
//
//  Created by Panajotis Maroungas on 25/02/16.
//  Copyright © 2016 Panajotis Maroungas. All rights reserved.
//

import UIKit

class PLKNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

		if let _ = Parking.sharedInstance.parkingLocation?.coordinates {
			if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(PKLUIStoryboardIdentifier.ParkingOverViewViewController.rawValue) {
				self.navigationController?.pushViewController(vc, animated: false)
			}
		}
    }
}
