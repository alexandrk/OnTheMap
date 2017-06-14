//
//  AddLocationPinControllerExt.swift
//  MeMe
//
//  Created by Alexander on 5/29/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

extension AddLocationPinController : UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        
        scrollView.contentSize = CGSize(
            width: scrollView.contentSize.width,
            height: scrollView.contentSize.height + 100)
    
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scrollView.isScrollEnabled = false
        
        scrollView.contentSize = CGSize(
            width: scrollView.contentSize.width,
            height: scrollView.contentSize.height - 100)
        
    }
    
}
