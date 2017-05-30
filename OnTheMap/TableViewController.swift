//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/24/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit

class TableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userLocations = [UserLocation]()
    var userID : String!
    var sessionID : String!
    var expirationTimestamp : String!
    
    override func viewDidLoad() {
        //requestLocationData()
        setTopNavigationBar()
        
        // Accessing data from the first tab of the UITabBarController
        let tabBarController = self.parent?.parent as! UITabBarController
        let navigationController = tabBarController.viewControllers?[0] as! UINavigationController
        let destinationViewController = navigationController.topViewController as! MapViewController
        
        // Saving data to local instance for ease of use
        self.userLocations = destinationViewController.userLocations
        self.userID = destinationViewController.userID
        self.sessionID = destinationViewController.sessionID
        self.expirationTimestamp = destinationViewController.expirationTimestamp
    }
    
    public func logOut() {
        HelperFuncs.logOut{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.userLocations.count == 0) ? 1 : self.userLocations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userLocationCell", for: indexPath) as! CustomTableViewCell
        let userLocation : UserLocation? = (self.userLocations.count == 0) ? nil : self.userLocations[indexPath.row]
        
        // Set the name and image
        if let userLocation = userLocation,
            userLocation.firstName != nil,
            userLocation.lastName != nil,
            userLocation.mediaURL != nil
        {
            cell.pinMainLabel?.text = "\(userLocation.firstName!) \(userLocation.lastName!)"
            cell.pinSublabel?.text = userLocation.mediaURL
            cell.pinDateCreatedLabel?.text = userLocation.createdAt
        }
        else {
            print("Found nil for name or mediaURL in the following record:")
            print(userLocation ?? "[User Location Collection is nil]")
            print("----------------------------------------")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userLocation = self.userLocations[indexPath.row]
        
        // Check to see if the link has a proper URL to be opened by a WebView
        // show error message otherwise
        if
            let urlString = userLocation.mediaURL,
            urlString.lowercased().hasPrefix("http")
                || urlString.lowercased().hasPrefix("https")
                || urlString.contains("://"),
            let url = URL(string: userLocation.mediaURL!)
        {
            // Show webView for the mediaURL provided
            UIApplication.shared.open(url)
        }
        else {
            // Accounting for nil and empty values of mediaURL
            let mediaURLDisplayValue = (userLocation.mediaURL == nil || userLocation.mediaURL == "")
                                            ? "link is empty"
                                            : userLocation.mediaURL!
            
            // Show message, instead of webView for incorrectly formatted URLs
            showAlert(message: "WARNING: Selected cell does not have a valid link: \(mediaURLDisplayValue)")
        }
    }
    
    func requestLocationData() {
        let request = NSMutableURLRequest(url: URL(string: Constants.UdacityParseDataURL + "?order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil { // Handle error...
                return
            }
            
            guard let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : Any] else {
                print("Could not parse Parse response into JSON")
                self.showAlert(message: "Something went wrong. Please try again.")
                return
            }
            
            let listOfLocations = json["results"] as? [[String:Any]]
            
            self.userLocations = UserLocation.userLocationsFromResults(listOfLocations!)
            
            HelperFuncs.performUIUpdatesOnMain {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            
        }
        task.resume()
        self.activityIndicator.startAnimating()
        
    }
    
    internal func showAlert(message: String) -> Void {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func setTopNavigationBar() {
        self.navigationItem.title = "ON THE MAP"
        let logOutButton = UIBarButtonItem(title: "LOGOUT",
                                           style: .done,
                                           target: self,
                                           action: #selector(self.logOut))
        self.navigationItem.setLeftBarButtonItems([logOutButton], animated: true)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(self.refreshData))
        let addItemButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(self.addLocationItem))
        self.navigationItem.setRightBarButtonItems([refreshButton, addItemButton], animated: true)
    }
    
    func refreshData(){
        userLocations = []
        tableView.reloadData()
        tableView.numberOfRows(inSection: 0)
        requestLocationData()
    }
    
    func addLocationItem(){
        
    }
    
}
