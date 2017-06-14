//
//  AppData.swift
//  OnTheMap
//
//  Created by Alexander on 6/2/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation

class AppData {
    var userID : String!
    var sessionID : String!
    var expirationTime : String!
    var arrayOfLocations : [UserLocation]!
    
    var firstName: String?
    var lastName : String?
    var latitude : Double!
    var longitude: Double!
    var locationString: String!
    var urlString: String!
    var userRecordParseID: String?
    
    // Used for syncing data between two tabs (on refresh button press),
    // and for signaling to refresh, when add new location was used
    var dataUpdatedForMapView: Bool = false
    var dataUpdatedForTableView: Bool = false
    var dataUpdateNeeded: Bool = false
    
    static let sharedInstance : AppData = AppData()
}
