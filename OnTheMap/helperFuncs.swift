//
//  helperFuncs.swift
//  OnTheMap
//
//  Created by Alexander on 5/15/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit

class HelperFuncs {

    /**
        Performs UI updates on Main (used in async calls)
     */
    static func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }

    @objc static func logOut(_ updates: @escaping () -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.UdacitySessionIDURL)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            self.performUIUpdatesOnMain {
                updates()
            }
        }
        task.resume()
    }
    
}
