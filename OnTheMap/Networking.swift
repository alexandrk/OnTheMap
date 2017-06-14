//
//  Networking.swift
//  OnTheMap
//
//  Created by Alexander on 5/29/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit

class Networking : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // authentication state
    var userID: String! = nil
    var sessionID: String! = nil
    var requestToken: String! = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }

    func taskForGetMethod(
        urlString : String,
        completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let udacityStripFirst5Characters =
            (urlString == Constants.UdacitySessionIDURL)
                || (urlString.contains(Constants.UdacityUserProfileURL)) ? true : false
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(_ error: String) {
                //print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    sendError("Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var newData = data
            if (udacityStripFirst5Characters) {
                // Striping away security purpose characters (as per API instructions)
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
        }
        task.resume()
    }

    func taskForPostPutMethod(
        httpMethod: String,
        urlString : String,
        jsonData  : String,
        completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        
        // Srip away security characters for udacity requests
        let udacityStripFirst5Characters =
            (urlString == Constants.UdacitySessionIDURL)
                || (urlString.contains(Constants.UdacityUserProfileURL)) ? true : false
        
        request.httpMethod = httpMethod

        // Add extra headers for parse requests
        if urlString.contains(Constants.UdacityPostUserDataURL) {
            request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Accept")
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in

            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPostPutMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                sendError("Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var newData = data
            if (udacityStripFirst5Characters) {
                // Striping away security purpose characters (as per API instructions)
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        task.resume()
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) -> Void{
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }

    // MARK: Shared Instance
    static let sharedInstance : Networking = Networking()
    
}
