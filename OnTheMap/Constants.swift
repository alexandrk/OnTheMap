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
    // * Login Page
    static let ButtonCornerRadius : CGFloat = 5
    static let DontHaveAnAccountText = "Don't have an account? Sign Up"
    static let DontHaveAnAccountLinkText = "Sign Up"
    static let UdacityCreateAccountURL = "https://udacity.com/account/auth#!/signup"
    static let DontHaveAnAccountFont = UIFont(descriptor: UIFontDescriptor(name: "System", size: CGFloat(16) ), size: CGFloat(16))
    
    // * Add Location Page
    static let WhereAreYouText = "Where are you\nstudying\ntoday?"
    static let WhereAreYouBold = "studying"
    static let WhereAreYouFont = UIFont(descriptor: UIFontDescriptor(name: "System", size: CGFloat(30) ), size: CGFloat(30))
    static let WhereAreYouBoldFont = UIFont.boldSystemFont(ofSize: 30)
    
    // MARK: Udacity JSON Request keys
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
    static let UdacityParseDataURL = "https://parse.udacity.com/parse/classes/StudentLocation" + "?limit=100&order=-updatedAt"
    static let UdacityUserProfileURL = "https://www.udacity.com/api/users/"
    static let UdacityPostUserDataURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    
    // MARK: PARSE Parameters
    static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let ParseAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    // MARK: Time Intervals
    static let addLocationAnimationDuration = 0.5
    
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
    
    struct Colors {
        static let darkBlue = UIColor(red:0.08, green:0.26, blue:0.45, alpha:1.0)
        static let lightBlue = UIColor(red:0.31, green:0.53, blue:0.71, alpha:1.0)
        static let greyish = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
        static let whiteSeeThrough = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.7)
    }
    
    struct UserData {
        static let missingName = "[[NO DATA FOR NAME]]"
        static let missingURL = "[[NO DATA FOR MEDIA URL]]"
    }
}
