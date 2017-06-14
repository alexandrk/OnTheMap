//
//  AddLocationPinController.swift
//  OnTheMap
//
//  Created by Alexander on 5/29/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddLocationPinController : UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var locationStringField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    @IBOutlet weak var enterURLLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var urlStringField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var submitBtnLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitBtnTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitBtnTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var findOmMapBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var findOmMapBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var findOmMapBtnLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var findOmMapBtnTrailingConstraint: NSLayoutConstraint!
    
    var fullUserProvidedAddress : String?
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Subscribe to keyboard events (keyboardWill[Show|Hide]), used to shift view
        // to display the bottom text field, while entering text into it
        subscribeToKeyboardNotifications()
        
        // Disables scroll view (only enabled, when keyboard is shown)
        self.scrollView.isScrollEnabled = false
        
        // Setup input fields delegates (needed for keyboard show/hide events)
        locationStringField.delegate = self
        urlStringField.delegate = self
        
        createCustomBorder(for: urlStringField)
        
        customTextViewString()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clean up
        unsubscribeFromKeyboardNotifications()
        
        // Make the navigation bar solid again
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Making navigation bar transparent
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        // Adding a Cancel button to right side of the navBar
        let cancelButton = UIBarButtonItem(title: "Cancel",
                                           style: .plain,
                                           target: self,
                                           action: #selector(self.cancelButtonAction(_:)))
        cancelButton.tintColor = Constants.Colors.darkBlue
        navigationItem.setRightBarButton(cancelButton, animated: false)
    }
    
    /// Requred to add round corners for the buttons
    override func viewDidLayoutSubviews() {
        //Round corners for buttons
        findOnMapButton.layer.cornerRadius = Constants.ButtonCornerRadius
        findOnMapButton.layer.masksToBounds = true
        submitBtn.layer.cornerRadius = Constants.ButtonCornerRadius
        submitBtn.layer.masksToBounds = true
        
    }
    
    /**
     Triggers different `cancel` effects, based on which state the controller is in.
     Enter location state **OR** Enter URL state
     */
    func cancelButtonAction(_ sender: AnyObject) {
        
        if submitBtn.alpha == 1 && !submitBtn.isHidden {
            transitionToLocation()
        }
        else {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    /**
        IBAction for 'Find on Map' button click
        Looks up entered location and picks the first result out of a returned array.
        Shows an error message, if no results where returned for the specified address.
    */
    @IBAction func findOnMapBtnClick(_ sender: Any) {
        
        guard let address = locationStringField.text else {
            HelperFuncs.showAlert(self, message: "Please enter the address")
            return
        }
        AppData.sharedInstance.locationString = address
        
        // Start Activity Indicator
        self.activityIndicator.startAnimating()
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(AppData.sharedInstance.locationString) {
            placemarks, error in
            
            /// Local helper function to display error during the request
            func errorFunc(_ error : Error){
                print(error)
                HelperFuncs.performUIUpdatesOnMain {
                    
                    // Stop Activity Indicator
                    self.activityIndicator.stopAnimating()
                    
                    HelperFuncs.showAlert(self, message: "Error finding a location\nPlease try again")
                    
                }
            }
            
            if error != nil {
                errorFunc(error!)
                return
            }
            guard let placemark = placemarks?.first else {
                errorFunc("Placemarks array is empty" as! Error)
                return
            }
            
            /// If Location was found, then:
            if let addressDictionary = placemark.addressDictionary as? [String: AnyObject],
               let addressArray = addressDictionary["FormattedAddressLines"] as? [String] {
                self.fullUserProvidedAddress = addressArray.joined(separator: " ")
            }
            else {
                self.fullUserProvidedAddress = AppData.sharedInstance.locationString
            }
            
            // Save lat, long into instance variables
            AppData.sharedInstance.latitude = placemark.location?.coordinate.latitude
            AppData.sharedInstance.longitude = placemark.location?.coordinate.longitude
            
            // Create annotation
            let annotation = self.createLocationPin(placemark: placemark, title: "Please verify the location:", subtitle: self.fullUserProvidedAddress)
            self.mapView.addAnnotation(annotation)
            
            // Select (open) provided annotation
            self.mapView.selectAnnotation(annotation, animated: false)
            
            // Focus map on the annotation region (1 delta degree = 111 kilometers (69 miles) at equator; 0 at the poles)
            let region = MKCoordinateRegion(center: annotation.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.mapView.setRegion(region, animated: false)
            
            // Transition to map and url field
            HelperFuncs.performUIUpdatesOnMain {
                self.transitionToMap()
                
                // Stop Activity Indicator
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    /**
     Helper function, used in findOnMapBtnClick IBAction
     - Returns: A new annotation based on information provided
     */
    private func createLocationPin(placemark: CLPlacemark, title: String?, subtitle: String?) -> MKPointAnnotation
    {
        // Create Annotation and add it to the map
        let annotation = MKPointAnnotation()
        annotation.coordinate = (placemark.location?.coordinate)!
        
        if let title = title {
            annotation.title = title
        }
        if let subtitle = subtitle {
            annotation.subtitle = subtitle
        }
        return annotation
    }
    
    /**
        Saves entered location and url information, associated with udacity userID back to the server
    */
    @IBAction func submitBtnClick(_ sender: Any) {
        
        // 1. Verify URL field is not empty and is in the correct format
        if let urlString = self.urlStringField.text {
            if let _ = urlString.range(of: "^(https?://)([a-zA-Z0-9\\.-]+)\\.([a-zA-Z0-9\\.]{2,6})",
               options: .regularExpression,
               range: nil,
               locale: nil)
            {
                AppData.sharedInstance.urlString = urlString
            }
            else {
                HelperFuncs.showAlert(self, message: "Please provide a valid url")
                return
            }
        }
        
        // Start Activity Indicator
        self.activityIndicator.startAnimating()
        
        // 2. Get Udacity Profile Inormation
        guard let userID = AppData.sharedInstance.userID else {
            
            // Stop Activity Indicator
            self.activityIndicator.stopAnimating()
            
            HelperFuncs.showAlert(self, message: "No Udacity User ID found.\nCannot continue.")
            return
        }
        
        // Load first name and last name from logged in user profile
        requestUdacityProfileInfo(userID)
        {
            // 3. Atempt to save new pin data
            self.saveNewPinData(){
                
                // Stop Activity Indicator
                self.activityIndicator.stopAnimating()
                
                // Used to trigger the data update, when either MapView or TableView is loaded
                AppData.sharedInstance.dataUpdateNeeded = true
                
                if (self.navigationController != nil) {
                    self.navigationController!.popViewController(animated: true)
                }
                
            }
            
        }
    }
    
    /**
        Attempts to get users data from Udacity, based on the login information.
        - Parameters:
            - userID: Udacity UserID, received as a response after login in.
            - completionHandler: Closure, used to execute code further, after request finishes.
    */
    private func requestUdacityProfileInfo(
        _ userID : String,
        _ completionHandler: @escaping () -> Void)
    {
        let urlString = Constants.UdacityUserProfileURL + userID
        
        Networking.sharedInstance.taskForGetMethod(urlString: urlString){
            result, error in
            
            if error != nil {
                HelperFuncs.showAlert(self, message: "Error retreiving Udacity information.\nPlease try again.")
                print(error ?? "[[ERROR is EMPTY]]")
                return
            }
            
            guard let result = result as? [String:AnyObject] else {
                HelperFuncs.showAlert(self, message: "Cannot get Udacity profile information")
                return
            }
            
            // Get Users First Name and Last Name
            let user = result["user"] as? [String:AnyObject]
            guard
                let firstName = user?["first_name"] as? String,
                let lastName = user?["last_name"] as? String
            else {
                HelperFuncs.showAlert(self, message: "Name missing from Udacity user profile. Cannot continue.")
                print("First OR Last name is missing")
                print(user ?? "[[NO DATA error in: \(#file) line: \(#line)]]")
                return
            }
            AppData.sharedInstance.firstName = firstName
            AppData.sharedInstance.lastName = lastName
            
            // Call completeion handler
            completionHandler()
        }
    }
    
    /**
        Posts new data to the parse db or updates an existing record, if one is already present
    */
    private func saveNewPinData(completionHandler: @escaping() -> Void){
        
        // Default values for variables, used when posting a new location
        // not updating an existing one
        var httpMethod = "POST"
        var methodURL = Constants.UdacityPostUserDataURL
        
        // Check to see if all the data is present
        guard
            let userID = AppData.sharedInstance.userID,
            let locationString = AppData.sharedInstance.locationString,
            let urlString = AppData.sharedInstance.urlString,
            let latitude = AppData.sharedInstance.latitude,
            let longitude = AppData.sharedInstance.longitude else {
                HelperFuncs.showAlert(self, message: "Missing some required data: (User ID, User Location or URL)")
                return
        }
        
        // Udate variables, if we are changing an existing record, instead of creating a new one
        if AppData.sharedInstance.userRecordParseID != nil {
            httpMethod = "PUT"
            methodURL += "/\(AppData.sharedInstance.userRecordParseID!)"
        }
        
        // Create JSON Body from the login fields
        let jsonBody =
            "{   \"uniqueKey\": \"\(userID)\"," +
                "\"firstName\": \"\(AppData.sharedInstance.firstName ?? "[[No first name]]")\"," +
                 "\"lastName\": \"\(AppData.sharedInstance.lastName ?? "[[No last name]]")\"," +
                "\"mapString\": \"\(locationString)\"," +
                 "\"mediaURL\": \"\(urlString)\"," +
                 "\"latitude\": \(latitude)," +
                "\"longitude\": \(longitude)" +
            "}"
        
        Networking.sharedInstance.taskForPostPutMethod(
            httpMethod: httpMethod,
            urlString: methodURL,
            jsonData: jsonBody){
                result, error in
                
                if error != nil {
                    HelperFuncs.showAlert(self, message: "There Was an Error Posting Your Data.\nPlease Try Again.")
                    print(error!)
                }
                
                HelperFuncs.performUIUpdatesOnMain {
                    completionHandler()
                }
        }
    }
    
    /**
        Creates bottom single line white border for specified field
        - Parameter field: field to set the border for
    */
    private func createCustomBorder(for field : UITextField) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height - width,
                              width:  field.frame.size.width,
                              height: field.frame.size.height)
        
        border.borderWidth = width
        field.layer.addSublayer(border)
        field.layer.masksToBounds = true
    }
    
    /**
        Animation functon, used to transition to a new state (Enter the URL) of the ViewController.
    */
    func transitionToMap(){
        
        // 0. Changes to navigation bar Cancel button
        let cancelButton = self.navigationItem.rightBarButtonItem
        cancelButton?.tintColor = UIColor.white
        cancelButton?.title = "Back"
        
        UIView.transition(with: scrollView, duration: Constants.addLocationAnimationDuration, options: .curveEaseIn, animations: {
            
            // 1. Animate textView
            self.textViewHeightConstraint.constant = 95    //orig: 135; new = orig - 40 (95)
            self.textView.alpha = 0
            self.enterURLLabel.alpha = 1
            self.containerView.backgroundColor = Constants.Colors.lightBlue
            
            // 2. Show Map
            self.self.mapView.alpha = 1
            
            // 3. Animate textfield for url
            self.urlStringField.alpha = 1
            
            // 4. Animate button replacement
            self.findOnMapButton.isHidden = true
            self.submitBtn.isHidden = false
            
            self.submitBtn.backgroundColor = Constants.Colors.whiteSeeThrough
            self.submitBtnLeadingConstraint.constant = 80   //orig: 25; new = 80
            self.submitBtnTrailingConstraint.constant = 80  //orig: 25; new = 80
            self.submitBtnBottomConstraint.constant = 35    //orig: 70; new = 35
            self.submitBtnTopConstraint.constant = 59       //orig: 24; new orig + 35 (59)
            
            self.findOnMapButton.backgroundColor = Constants.Colors.whiteSeeThrough
            self.findOmMapBtnLeadingConstraint.constant = 80    //orig: 25; new = 80
            self.findOmMapBtnTrailingConstraint.constant = 80   //orig: 25; new = 80
            self.findOmMapBtnBottomConstraint.constant = 35     //orig: 70; new = 35
            self.findOmMapBtnTopConstraint.constant = 59        //orig: 24; new orig + 35 (59)
            
            self.view.layoutIfNeeded()
        })
//        { success in
//        }
        
    }
    
    /**
        Animation functon. The reverse of the **transitionToMap** functon
    */
    func transitionToLocation(){
        
        // 0. Changes to navigation bar Cancel button
        let cancelButton = self.navigationItem.rightBarButtonItem
        cancelButton?.tintColor = Constants.Colors.darkBlue
        cancelButton?.title = "Cancel"
        
        UIView.transition(with: scrollView, duration: Constants.addLocationAnimationDuration, options: .curveEaseIn, animations: {
            
            //Transition Back
            
            // 1. Animate textView
            self.textViewHeightConstraint.constant = 135    //orig: 135; new = orig - 40 (95)
            self.textView.alpha = 1
            self.enterURLLabel.alpha = 0
            self.containerView.backgroundColor = Constants.Colors.greyish
            self.customTextViewString()
            
            // 2. Show Map
            self.self.mapView.alpha = 0
            
            // 3. Animate textfield for url
            self.urlStringField.alpha = 0
            
            // 4. Animate button replacement
            self.findOnMapButton.isHidden = false
            self.submitBtn.isHidden = true
            
            self.submitBtn.backgroundColor = UIColor.white
            self.submitBtnLeadingConstraint.constant = 25   //orig: 25; new = 80
            self.submitBtnTrailingConstraint.constant = 25  //orig: 25; new = 80
            self.submitBtnBottomConstraint.constant = 70    //orig: 70; new = 35
            self.submitBtnTopConstraint.constant = 24       //orig: 24; new orig + 35 (59)
            
            
            self.findOnMapButton.backgroundColor = Constants.Colors.whiteSeeThrough
            self.findOmMapBtnLeadingConstraint.constant = 25    //orig: 25; new = 80
            self.findOmMapBtnTrailingConstraint.constant = 25   //orig: 25; new = 80
            self.findOmMapBtnBottomConstraint.constant = 70     //orig: 70; new = 35
            self.findOmMapBtnTopConstraint.constant = 24        //orig: 24; new orig + 35
            
            self.view.layoutIfNeeded()
        })
//        { success in
//        }
        
    }
    
    /**
        Helper function used to setup desired styling of the text in the textView area
        _"Where are you studying today"_ text
    */
    private func customTextViewString(){
        // Do custom styling for text in the textView
        let whereAreYouAS = NSMutableAttributedString(string: Constants.WhereAreYouText)
        let foundRange = whereAreYouAS.mutableString.range(of: Constants.WhereAreYouBold)
        
        // Font size attribute. Size needs to be set programatically, since we are using custom attributes for the textView
        let allStringRange = NSMakeRange(0, whereAreYouAS.length)
        
        whereAreYouAS.addAttribute(NSFontAttributeName,
                                   value: Constants.WhereAreYouFont,
                                   range: allStringRange)
        whereAreYouAS.addAttribute(NSForegroundColorAttributeName,
                                   value: Constants.Colors.darkBlue,
                                   range: allStringRange)
        
        // Aligning text programatically, since we are using custom attributes for the textView
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        whereAreYouAS.addAttribute(NSParagraphStyleAttributeName,
                                   value: paragraph,
                                   range: allStringRange)
        
        // Creating a bold face for a given part of the string
        whereAreYouAS.addAttribute(NSFontAttributeName,
                                   value: Constants.WhereAreYouBoldFont,
                                   range: foundRange)
        
        textView.attributedText = whereAreYouAS
    }
}
