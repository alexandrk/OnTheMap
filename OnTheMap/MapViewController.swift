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

class MapViewController: UIViewController, CustomTabBarControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // If data has not been loaded yet, request it
        if AppData.sharedInstance.arrayOfLocations == nil {
            
            // Request Pin data
            self.getPinDataAndPopulateMap()
        }
        else {
            self.populateMapWithPins()
        }
    }
    
    /// CustomTabBarControllerProtocol function implementation
    func refreshBtnPressed(_ sender: AnyObject) {

        // remove stored location data
        AppData.sharedInstance.arrayOfLocations = nil
        
        // remove all annotations from the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // request new data and populate the map
        getPinDataAndPopulateMap()
        
    }
    
    /// Creates pins for each location in the AppData and adds them on the map
    internal func populateMapWithPins() {
        var annotationsArray = [MKPointAnnotation]()
        for location in AppData.sharedInstance.arrayOfLocations {

            // Create Annotations based on AppData
            guard
                let latitude = location.latitude,
                let longitude = location.longitude else {
//                    print("----| Missing Location Data |----")
//                    print(location)
                    continue
            }
            let clLocation = CLLocationCoordinate2DMake(latitude, longitude)
            

            // Setting up annotation
            
            // 1. Setting up title
            let annotation          = MKPointAnnotation()
            annotation.coordinate   = clLocation
            if
                let firstName = location.firstName,
                let lastName = location.lastName,
                firstName != "", lastName != ""
            {
                annotation.title    = "\(firstName) \(lastName)"
            }
            else {
                annotation.title    = Constants.UserData.missingName
            }
            
            // 2. Setting up subtitle
            if let mediaURL = location.mediaURL, mediaURL != "" {
                annotation.subtitle = "\(mediaURL)"
            }
            else {
                annotation.subtitle = Constants.UserData.missingURL
            }
            annotationsArray.append(annotation)
        }
        
        HelperFuncs.performUIUpdatesOnMain {
            self.mapView.addAnnotations(annotationsArray)
            self.activityIndicator.stopAnimating()
        }
    }
    
    /**
     Convenience method. Combines tasks of getting data and populating the map in one.
     Used on initial load and refresh button press
     */
    internal func getPinDataAndPopulateMap()
    {
        // Start activity indicator
        self.activityIndicator.startAnimating()
        
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
            
            self.populateMapWithPins()
            
        }
    }

}

extension MapViewController : MKMapViewDelegate {
    
    /// Creates annotations with callouts,
    /// callouts are used to add click event to annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let view : MKPinAnnotationView
        let identifier = "any"
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        }
        return view
    
    }
    
    /// Adds webView forwarding to annotations with proper links
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        guard let anotation = view.annotation else {return}
        if (control == view.rightCalloutAccessoryView)
        {
            if let urlString = anotation.subtitle,
                urlString != Constants.UserData.missingURL,
                let url = URL(string: urlString!),
                UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url)
            }
            else {
                HelperFuncs.showAlert(self, message: "Invalid URL\nPlease try another pin")
            }
        }
    }
}
