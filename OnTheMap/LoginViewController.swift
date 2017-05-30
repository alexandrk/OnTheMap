//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/13/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var userID : String!
    var sessionID : String!
    var expirationTimestamp : String!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnUdacityLogin: UIButton!
    @IBOutlet weak var tvDontHaveAccount: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        // Subscribe to keyboard events (keyboardWill[Show|Hide]), used to shift view
        // to display the bottom text field, while entering text into it
        subscribeToKeyboardNotifications()
        
        // Disables scroll view (only enabled, when keyboard is shown)
        self.scrollView.isScrollEnabled = false
        
        self.navigationController?.isNavigationBarHidden = true
        
        // Setup input fields delegates (needed for keyboard show/hide events)
        txtEmail.delegate = self
        txtPassword.delegate = self
        
        // Resetting the border style for text fields back to rounded corners,
        // done programatically, since we have custom text fields height
        txtEmail.borderStyle = UITextBorderStyle.roundedRect
        txtPassword.borderStyle = UITextBorderStyle.roundedRect
        
        let dontHaveAccountAS = NSMutableAttributedString(string: Constants.DontHaveAnAccountText)
        let foundRange = dontHaveAccountAS.mutableString.range(of: Constants.DontHaveAnAccountLinkText)
        
        // Font size attribute. Size needs to be set programatically, since we are using custom attributes for the textView
        dontHaveAccountAS.addAttribute(NSFontAttributeName,
                                       value: Constants.DontHaveAnAccountFont,
                                       range: NSMakeRange(0, dontHaveAccountAS.length))
        
        // Creating a link for a given part of the string
        dontHaveAccountAS.addAttribute(NSLinkAttributeName,
                                       value: URL(string: Constants.UdacityCreateAccountURL)!,
                                       range: foundRange)
        
        // Aligning text programatically, since we are using custom attributes for the textView
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        dontHaveAccountAS.addAttribute(NSParagraphStyleAttributeName,
                                       value: paragraph,
                                       range: NSMakeRange(0, dontHaveAccountAS.length))
        
        tvDontHaveAccount.attributedText = dontHaveAccountAS
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean up
        unsubscribeFromKeyboardNotifications()
        
        // Adds navigation bar back in, when the login controller is not on top anymore
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        //Round corners for login button
        self.btnUdacityLogin.layer.cornerRadius = Constants.ButtonCornerRadius
        self.btnUdacityLogin.layer.masksToBounds = true
        
    }
    
    @IBAction func dontHaveAccountClick(_ sender: Any) {
        UIApplication.shared.open(URL(string: Constants.UdacityCreateAccountURL)!)
    }

    /**
     Login button action. Logs into Udacity Account.
     - UNSECURE, sends passwords over HTTP unencrypted
     */
    @IBAction func loginClick(_ sender: Any)
    {
        
        // Check if both fields are filled out, present alert, if either one is empty
        guard let loginFieldValue =  txtEmail.text,
            !loginFieldValue.isEmpty,
            let passwordFIeldValue = txtPassword.text,
            !passwordFIeldValue.isEmpty
        else {
            showAlert(message: "Empty Email or Password")
            return
        }
        
        let url = URL(string: Constants.UdacitySessionIDURL)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Accept")
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let jsonBody = [
            "udacity": [
                Constants.UdacityRequestLogin        : loginFieldValue,
                Constants.UdacityRequestPassword : passwordFIeldValue
            ]
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted) else {
            print("Could not parse data into JSON: \(jsonBody)")
            return
        }
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            HelperFuncs.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
            
            // Handle error (Network issues or Web Service reachability)
            if error != nil
            {
                HelperFuncs.performUIUpdatesOnMain {
                    self.showAlert(message: "The seems to be an issue connecting to Udacity Web Service. Please check your internet connection and try again.")
                }
                print("ERROR: \(error!)")
                if let response = response {
                    print("RESPONSE: \(response)")
                }
                
                return
            }
            
            // Parsing the response
            
            // Striping away security purposes characters
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            guard let json = try! JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as? [String : Any] else {
                print("Could not parse Udacity response into JSON")
                self.showAlert(message: "Something went wrong. Please try again.")
                return
            }
            
            /**
            JSON, if login unsuccessful has two keys:
                - status_code
                - message
            if successful:
             {
                 "account": {
                     "registered": true,
                     "key": "3903878747"
                 },
                 "session": {
                     "id": "1457628510Sc18f2ad4cd3fb317fb8e028488694088",
                     "expiration": "2015-05-10T16:48:30.760460Z"
                 }
             }
            */
            if let statusCode = json[Constants.UdacityResponseStatus] as? Int {
            
                print("Udacity Login Request Status Code: \(statusCode)")

                // Show message to a user about unsuccessful login
                HelperFuncs.performUIUpdatesOnMain {
                    if let error = json[Constants.UdacityResponseError] as? String {
                        self.showAlert(message: error)
                    }
                }
                return
            }
            
            // If account exists and all is good
            if let account = json[Constants.UdacityResponseAccount] as? [String : Any],
                let registered = account[Constants.UdacityResponseRegistered] as? Bool,
                let session = json[Constants.UdacityResponseSession] as? [String : Any],
                registered == true
            {
                self.userID = account[Constants.UdacityResponseUserID] as! String
                self.sessionID = session[Constants.UdacityResponseSessionID] as! String
                self.expirationTimestamp = session[Constants.UdacityResponseSessionExpiration] as! String
                
                print("User ID: \(self.userID)")
                print("Session ID: \(self.sessionID)")
                print("Expiration Timestamp: \(self.expirationTimestamp)")
                
                
                // TEMPORARY (in place of segue transition to a map view)
                HelperFuncs.performUIUpdatesOnMain {
                    //self.showAlert(message: "All is good, ready to move to the Map view")
                    self.performSegue(withIdentifier: "loginSuccessfulSegue", sender: self)
                }
                
            }

            return
        }
        task.resume()
        self.activityIndicator.startAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabBarController = segue.destination as! UITabBarController
        
        let navigationController = tabBarController.viewControllers![0] as! UINavigationController
        let destinationViewController = navigationController.topViewController as! MapViewController
        
        // If not embeded in navBarController
        //let destinationViewController = tabBarController.viewControllers![0] as! MapViewController
        
        destinationViewController.userID = self.userID
        destinationViewController.sessionID = self.sessionID
        destinationViewController.expirationTimestamp = self.expirationTimestamp
    }
    
    internal func showAlert(message: String) -> Void {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

