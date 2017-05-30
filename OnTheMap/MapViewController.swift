//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/19/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {

    var userID : String!
    var sessionID : String!
    var expirationTimestamp : String!
    
    var userLocations : [UserLocation]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mapView != nil {
            requestPinData()
        }
        else {
            print("mapView is not initialized")
        }
        
        setTopNavigationBar()
    }
    
    public func logOut() {
        HelperFuncs.logOut{
            self.dismiss(animated: true, completion: nil)
        }
    }
   
    @IBAction func refreshBtnPressed(_ sender: Any) {

        if mapView != nil {
            userLocations = nil
            // remove all annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            requestPinData()
        }
        else {
            print("mapView is not initialized")
        }
    }
    
    func requestPinData() {
        let request = NSMutableURLRequest(url: URL(string: Constants.UdacityParseDataURL + "?limit=4000&order=-updatedAt")!)
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
            
            // Populate Map with Pins from Parse data
            //let span : MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
            var annotationsArray = [MKPointAnnotation]()
            for location in self.userLocations {
                
                if location.latitude == nil || location.longitude == nil {
                    print("Location is nil for the following record:")
                    print(location)
                    print("--------------------------------------------------")
                    continue
                }
                
                let clLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(
                                                                location.latitude!,
                                                                location.longitude!)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = clLocation
                annotation.title = "\(location.firstName!) \(location.lastName!)"
                if let mediaURL = location.mediaURL {
                    annotation.subtitle = "\(mediaURL)"
                }
                annotationsArray.append(annotation)
                
                if location.latitude == nil ||
                    location.longitude == nil ||
                    location.firstName == nil ||
                    location.lastName == nil ||
                    location.mediaURL == nil {
                    print("--------------")
                    print("First Name: \(location.firstName ?? "NIL")")
                    print("Last Name: \(location.lastName ?? "NIL")")
                    print("Latitude: \(location.latitude ?? 0)")
                    print("Longitude: \(location.longitude ?? 0)")
                    print("Media URL: \(location.mediaURL ?? "NIL")")
                }
            }
            
            //let region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            HelperFuncs.performUIUpdatesOnMain {
                self.mapView.addAnnotations(annotationsArray)
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
                                            action: #selector(self.refreshBtnPressed))
        let addItemButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(self.addLocationItem))
        self.navigationItem.setRightBarButtonItems([refreshButton, addItemButton], animated: true)
    }
    
    func addLocationItem(){
        // 1. Check to see if logged in user, already has a record in the dataset
        //    1.a. => Yes, ask, if the user wants to override it with the new one
        //    1.b. => No, return (do nothing)
        // 2. If no record found, post a new one to the dataset
        for userLocation in userLocations {
            if let userLocationUdacityID = userLocation.udacityID {
                
                if String(userLocationUdacityID) == self.userID {
                    showAlert(message: "You have a record: \(userLocation)")
                }
                
            }
//            else {
//                print("Name: \(userLocation.firstName ?? "[No First Name]") \(userLocation.firstName ?? "[No Last Name]")")
//                print("UdacityID: \(String(describing: userLocation.udacityID))")
//                print("------------------------------------")
//            }
//            print(userLocation)
//            print("------------------------------------")
        }
    }

}
