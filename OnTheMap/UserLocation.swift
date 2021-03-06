//
//  UserLocation.swift
//  OnTheMap
//
//  Created by Alexander on 5/23/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation

struct UserLocation {
    
    /*
    "createdAt": "2015-02-25T01:10:38.103Z",
    "firstName": "Jarrod",
    "lastName": "Parkes",
    "latitude": 34.7303688,
    "longitude": -86.5861037,
    "mapString": "Huntsville, Alabama ",
    "mediaURL": "https://www.linkedin.com/in/jarrodparkes",
    "objectId": "JhOtcRkxsh",
    "uniqueKey": "996618664",
    "updatedAt": "2015-03-09T22:04:50.315Z"
     */

    let firstName : String?
    let lastName  : String?
    let latitude  : Double?
    let longitude : Double?
    let mapString : String?
    let mediaURL  : String?
    let parseID   : String
    let udacityID : String?
    let createdAt : String
    let updatedAt : String
    
    // construct a UserLocation from a dictionary object
    init(dictionary: [String:AnyObject]) {
        
        firstName = dictionary[Constants.UserLocation.firstName] as? String
        lastName  = dictionary[Constants.UserLocation.lastName]  as? String
        latitude  = dictionary[Constants.UserLocation.latitude]  as? Double
        longitude = dictionary[Constants.UserLocation.longitude] as? Double
        mapString = dictionary[Constants.UserLocation.mapString] as? String
        mediaURL  = dictionary[Constants.UserLocation.mediaURL]  as? String
        parseID   = dictionary[Constants.UserLocation.parseID]   as! String
        udacityID = dictionary[Constants.UserLocation.udacityID] as? String
        createdAt = dictionary[Constants.UserLocation.createdAt] as! String
        updatedAt = dictionary[Constants.UserLocation.updatedAt] as! String
    }
    
    static func userLocationsFromResults(_ results: [[String:AnyObject]]) -> [UserLocation] {
        
        var userLocations = [UserLocation]()
        
        // iterate through array of dictionaries, each UserLocation is a dictionary
        for result in results {
            userLocations.append(UserLocation(dictionary: result))
        }
        
        return userLocations
    }

}
