//
//  ViewControllerExt.swift
//  MeMe
//
//  Created by Alexander on 10/4/16.
//  Copyright © 2016 Dictality. All rights reserved.
//

import UIKit

extension ViewController : UITextFieldDelegate {
    
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
    
    // FIXME: Fix, so the function would actually run on touch and remove the keyboard (also triggering the disable scroll?)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        print("TOUCH: \(touches.count)")
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
