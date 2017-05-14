//
//  ViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/13/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnUdacityLogin: UIButton!
    @IBOutlet weak var tvDontHaveAccount: UITextView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                                       value: Constants.UdacityCreateAccountURL,
                                       range: foundRange)
        
        // Aligning text programatically, since we are using custom attributes for the textView
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        dontHaveAccountAS.addAttribute(NSParagraphStyleAttributeName,
                                       value: paragraph,
                                       range: NSMakeRange(0, dontHaveAccountAS.length))
        
        tvDontHaveAccount.attributedText = dontHaveAccountAS
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        
        //Round corners for login button
        self.btnUdacityLogin.layer.cornerRadius = Constants.ButtonCornerRadius
        self.btnUdacityLogin.layer.masksToBounds = true
        
        //Color "Sign Up" - blue on a 'Don't have account? Sign Up' button
        
        
    }
    
    @IBAction func dontHaveAccountClick(_ sender: Any) {
        
        UIApplication.shared.open(Constants.UdacityCreateAccountURL)
        
    }

    @IBAction func loginClick(_ sender: Any) {
        //Verify Login/Password combo againts Udacity API
    }
    
}

