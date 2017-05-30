//
//  Constants.swift
//  OnTheMap
//
//  Created by Alexander on 5/13/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit

struct Constants
{
    
    // MARK: App UI Constants
    static let ButtonCornerRadius : CGFloat = 5
    static let DontHaveAnAccountText : String = "Don't have an account? Sign Up"
    static let DontHaveAnAccountLinkText : String = "Sign Up"
    static let UdacityCreateAccountURL = "https://udacity.com/account/auth#!/signup"
    
    static let DontHaveAnAccountFont : UIFont  = UIFont(descriptor: UIFontDescriptor(name: "System", size: CGFloat(16) ), size: CGFloat(16))
    
    // MARK: Udacity JSON Request kets
    static let UdacityRequestLogin = "username"
    static let UdacityRequestPassword = "password"
    
    //  MARK: Udacity JSON Response keys
    static let UdacityResponseStatus = "status"
    static let UdacityResponseError = "error"
    
    static let UdacityResponseAccount = "account"
    static let UdacityResponseRegistered = "registered"
    static let UdacityResponseUserID = "key"
    static let UdacityResponseSession = "session"
    static let UdacityResponseSessionID = "id"
    static let UdacityResponseSessionExpiration = "expiration"
    
    // MARK: URLS
    static let UdacitySessionIDURL = "https://www.udacity.com/api/session"
    static let UdacityParseDataURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    
    // MARK: Parse `UserLocation` JSON Response keys
    struct UserLocation
    {
        static let firstName = "firstName"
        static let lastName  = "lastName"
        static let latitude  = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL  = "mediaURL"
        static let parseID   = "objectId"
        static let udacityID = "uniqueKey"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
}
