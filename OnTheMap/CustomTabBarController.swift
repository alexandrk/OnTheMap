//
//  CustomTabBarControllerViewController.swift
//  OnTheMap
//
//  Created by Alexander on 5/31/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit
import MapKit

protocol CustomTabBarControllerDelegate : class {
    func refreshBtnPressed(_ sender: AnyObject)
}

class CustomTabBarController: UITabBarController {

    var customDelegate : CustomTabBarControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
    
        navigationItem.title = "ON THE MAP"
        let logOutButton = UIBarButtonItem(title: "LOGOUT",
                                           style: .done,
                                           target: self,
                                           action: #selector(self.logOut))
        navigationItem.setLeftBarButtonItems([logOutButton], animated: true)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(self.refreshBtnPressed))
        let addItemButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(self.addLocationItem))
        navigationItem.setRightBarButtonItems([refreshButton, addItemButton], animated: true)
        
    }
    
    public func logOut() {
        HelperFuncs.logOut{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func refreshBtnPressed(_ sender: AnyObject){
        self.customDelegate?.refreshBtnPressed(sender)
        //printCurrentTab()
    }
    
    func addLocationItem(_ overwrite: Bool = false){
        
        // Check to see, if overwrite flag is set, so we can skip the section and continue
        if overwrite == false {
            let recordExists = checkPreviousEntries()
            
            // Showing the prompt, therefor canceling further flow until user action
            if recordExists == true {
                return
            }
        }
        
        guard let currentViewController = self.customDelegate as? UIViewController else {
            print("Could cast deletegate as UIViewController")
            print(printCurrentTab())
            return
        }
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AddLocationPinControllerID") as? AddLocationPinController else
        {
            print("Could not instantiate view controller with identifier AddLocationPinControllerID of type AddLocationPinController")
            return
        }

        currentViewController.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // Check to see, if user already created a record
    internal func checkPreviousEntries() -> Bool{
        
        for userLocation in AppData.sharedInstance.arrayOfLocations {
            if let userLocationUdacityID = userLocation.udacityID {
                
                if String(userLocationUdacityID) == AppData.sharedInstance.userID {
                    
                    let alert = UIAlertController(
                        title: nil,
                        message: "You Have Already Posted a Student Location. Would You Like to Overwrite it?",
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(
                        title: "Overwrite",
                        style: UIAlertActionStyle.default,
                        handler: {
                            alert in
                            AppData.sharedInstance.userRecordParseID = userLocation.parseID
                            self.addLocationItem(true)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                    
                    HelperFuncs.performUIUpdatesOnMain {
                        self.present(alert, animated: true, completion: nil)
                    }
                    return true
                }
    
            }
        }
        return false
    }
    
    internal func printCurrentTab(){
        if (self.customDelegate as? MapViewController) != nil {
            print("mapView")
        }
        else if (self.customDelegate as? TableViewController) != nil {
            print("tableView")
        }
        else {
            print("couldn't cast the delegate property to neither MKMapView nor UITableView")
        }

    }

}
