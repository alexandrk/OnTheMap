//
//  LoggedInMapViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/19/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LoggedInMapViewController: UIViewController {

    var userID : String!
    var sessionID : String!
    var expirationTimestamp : String!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("userID: \(userID)")
        print("sessionID: \(sessionID)")
        print("Expiration: \(expirationTimestamp)")
        
    }
   

}
