//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/13/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

extension LoginViewController {
    
}

class LoginViewController: UIViewController {
    
    var userID : String!
    var sessionID : String!
    var expirationTimestamp : String!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnUdacityLogin: UIButton!
    @IBOutlet weak var tvDontHaveAccount: UITextView!
    @IBOutlet weak var containerView: UIView!
    var containerViewOrigin: CGPoint!
    
    override func viewWillAppear(_ animated: Bool){
        
        //Round corners for login button
        self.btnUdacityLogin.layer.cornerRadius = Constants.ButtonCornerRadius
        //self.btnUdacityLogin.layer.masksToBounds = true
        
        // Subscribe to keyboard events (keyboardWill[Show|Hide]), used to shift view
        // to display the bottom text field, while entering text into it
        subscribeToKeyboardNotifications()
        
        // Setup input fields delegates (needed for keyboard show/hide events)
        txtEmail.delegate = self
        txtPassword.delegate = self
        
        // Resetting the border style for text fields back to rounded corners,
        // done programatically, since we have custom text fields height
        txtEmail.borderStyle = UITextBorderStyle.roundedRect
        txtPassword.borderStyle = UITextBorderStyle.roundedRect
        
        // Seting up custom styling for dontHaveAccountTextView
        setupCustomStylingForDontHaveAccountTextView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        // Unsubscribe from keyboard events
        unsubscribeFromKeyboardNotifications()
    }
    
    /**
        Sets up custom styling for 'Dont have an account Text View'.
        - Implemented as AttributedString to add link to a specific part of the string.
        - Font size and alignment needs to be set manually, since we are using custom attributes.
    */
    private func setupCustomStylingForDontHaveAccountTextView(){
        let dontHaveAccountAS   = NSMutableAttributedString(string: Constants.DontHaveAnAccountText)
        let foundRange          = dontHaveAccountAS.mutableString.range(of: Constants.DontHaveAnAccountLinkText)
        let fullStringRange     = NSMakeRange(0, dontHaveAccountAS.length)
        
        // Creating a link for a given part of the string
        dontHaveAccountAS.addAttribute(NSLinkAttributeName,
                                       value: URL(string: Constants.UdacityCreateAccountURL)!, range: foundRange)
        
        // Set alignment and font size
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        dontHaveAccountAS.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: fullStringRange)
        dontHaveAccountAS.addAttribute(NSFontAttributeName, value: Constants.DontHaveAnAccountFont, range: fullStringRange)
        
        //Add attributed string to the textView
        tvDontHaveAccount.attributedText = dontHaveAccountAS
    }

    /**
     Login button action. Logs into Udacity Account.
     - **UNSECURE**, sends passwords over HTTP unencrypted
     */
    @IBAction func loginClick(_ sender: AnyObject)
    {
        // Start Activity Indicator, before making a Network request
        self.activityIndicator.startAnimating()
        
        Networking.sharedInstance.loginClickHandler(loginFieldValue: txtEmail.text, passwordFieldValue: txtPassword.text){
            result, error in
            
            // Stop Activity Indicator
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                print(error.domain)
                HelperFuncs.showAlert(self, message: error.localizedDescription)
                return
            }
            
            // At this poin `result` should never be nil
            if result == nil {
                print("\(#function) line #\(#line). `result` should never be nil")
                HelperFuncs.showAlert(self, message: "Something went wrong.\nPlease try again.")
                return
            }
            
            // If account exists and all is good, save the credentials to AppData.SharedInstance
            if let account      = result?[Constants.UdacityResponseAccount] as? [String : AnyObject],
                let registered  = account[Constants.UdacityResponseRegistered] as? Bool,
                let session     = result?[Constants.UdacityResponseSession] as? [String : AnyObject],
                registered == true
            {
                AppData.sharedInstance.userID         = account[Constants.UdacityResponseUserID] as! String
                AppData.sharedInstance.sessionID      = session[Constants.UdacityResponseSessionID] as! String
                AppData.sharedInstance.expirationTime = session[Constants.UdacityResponseSessionExpiration] as! String
                
                HelperFuncs.performUIUpdatesOnMain {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil)
                        .instantiateViewController(withIdentifier: "NavigationControllerStoryboardID")
                        as? UINavigationController else
                    {
                        print("Could not instantiate view controller with identifier NavigationControllerStoryboardID of type UINavigationController")
                        return
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        
        
    }
    
}

