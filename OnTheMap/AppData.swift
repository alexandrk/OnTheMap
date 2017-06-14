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
    
    static let sharedInstance : AppData = AppData()
}
