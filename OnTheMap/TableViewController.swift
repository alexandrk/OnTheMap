//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/24/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit

class TableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, CustomTabBarControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        // Setting up a custom delegate field for CustomTabBarController
        // Controlls which view to apply the buttons in the navigation bar to
        guard let tabBarController = self.parent as? CustomTabBarController else {
            print("Couldn't cast 'self.parent' as 'CustomTabBarController'")
            return
        }
        tabBarController.customDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (AppData.sharedInstance.dataUpdatedForTableView) {
            tableView.reloadData()
            AppData.sharedInstance.dataUpdatedForTableView = false
        }
    }
    
    override func viewDidLoad() {
        
        // If data has not been loaded yet, request it
        if AppData.sharedInstance.arrayOfLocations == nil {
            
            // Request Pin data
            self.getPinDataAndRefreshTable()
        }
        else {
            self.tableView.reloadData()
        }
    }
    
    /// UITableViewDataSource required function
    /// Tells the data source to return the number of rows in a given section of a table view.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (AppData.sharedInstance.arrayOfLocations == nil) ? 0 : AppData.sharedInstance.arrayOfLocations.count
    }
    
    /// UITableViewDataSource required function
    /// Asks the data source for a cell to insert in a particular location of the table view.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userLocationCell", for: indexPath) as! CustomTableViewCell
        let userLocation : UserLocation? = AppData.sharedInstance.arrayOfLocations == nil ? nil : AppData.sharedInstance.arrayOfLocations[indexPath.row]
        
        if let userLocation = userLocation {
            let firstName = (userLocation.firstName != nil && (userLocation.firstName?.characters.count)! > 0) ?
                userLocation.firstName! : "[[First Name Missing]]"
            let lastName = (userLocation.lastName != nil && (userLocation.lastName?.characters.count)! > 0) ?
                userLocation.lastName! : "[[Last Name Missing]]"
            let mediaURL = (userLocation.mediaURL != nil && (userLocation.mediaURL?.characters.count)! > 0) ?
                userLocation.mediaURL! : "[[Media URL Missing]]"
            
            cell.pinMainLabel?.text = "\(firstName) \(lastName)"
            cell.pinSublabel?.text = mediaURL
            //cell.pinDateCreatedLabel?.text = "Created At: \(userLocation.createdAt)"
            //cell.pinDateCreatedLabel?.text = "Udacity ID: \(userLocation.udacityID ?? "[[no data for udacityID]]")"
        
        }
        return cell
    }
    
    /// UITableViewDataSource optional function
    /// Used to perform action on cell selection by user
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userLocation = AppData.sharedInstance.arrayOfLocations[indexPath.row]
        
        // Check to see if the link has a proper URL to be opened by a WebView
        // show error message otherwise
        if
            let urlString = userLocation.mediaURL,
            (urlString.lowercased().hasPrefix("http") || urlString.lowercased().hasPrefix("https")) && urlString.contains("://"),
            let url = URL(string: userLocation.mediaURL!)
        {
            // Show webView for the mediaURL provided
            UIApplication.shared.open(url)
        }
        else {
            HelperFuncs.showAlert(self, message: "Invalid Link")
        }
    }
    
    /// CustomTabBarControllerProtocol function implementation
    func refreshBtnPressed(_ sender: AnyObject) {
        
        // Remove old data
        AppData.sharedInstance.arrayOfLocations = nil
        tableView.reloadData()
        
        // Request new data and refresh table on success
        // Start activity indicator
        self.activityIndicator.startAnimating()
        
        getPinDataAndRefreshTable()
        
        // Used to indicate that refresh of the mapView is needed, when it is going to be loaded
        AppData.sharedInstance.dataUpdatedForMapView = true
    }
    
    /**
     Convenience method. Combines tasks of getting data and refreshing the table in one.
     Used on initial load and refresh button press
     */
    internal func getPinDataAndRefreshTable(){
        Networking.sharedInstance.taskForGetMethod(urlString: Constants.UdacityParseDataURL) {
            result, error in
            
            if error != nil {
                HelperFuncs.showAlert(self, message: "Error while retreiving pin data")
                print(error ?? "[[ERROR is EMPTY]]")
                HelperFuncs.performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            guard let result = result else {
                HelperFuncs.showAlert(self, message: "No pin data found")
                return
            }
            
            let listOfLocations = result["results"] as? [[String:AnyObject]]
            AppData.sharedInstance.arrayOfLocations = UserLocation.userLocationsFromResults(listOfLocations!)
            
            // Reload table on new data
            HelperFuncs.performUIUpdatesOnMain {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            
        }
    }
    
}
