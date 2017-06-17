//
//  AddLocationPinControllerExt.swift
//  MeMe
//
//  Created by Alexander on 5/29/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

extension AddLocationPinController : UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                
                // Screen height
                let screenHeight = UIScreen.main.bounds.height
                
                // Keyboard height
                let keyboardHeight = keyboardFrame.height
                
                // TextFieldBottom position on screen
                var textFieldBottomY: CGFloat = 0
                // Pick proper text field, depending on the ViewController state
                if (!mapViewShown){
                    textFieldBottomY = centerView.frame.origin.y
                                     + locationStringField.frame.origin.y
                                     + locationStringField.frame.height
                }
                else {
                    textFieldBottomY = urlStringField.frame.origin.y
                                     + urlStringField.frame.height
                }
                
                // Difference between textFieldBottom and Bottom of the Screen
                let textFieldToBottom = screenHeight - textFieldBottomY
                
                // Shift screen up on the difference between keyboard height and textFieldToBottom
                let shiftAmount = keyboardHeight - textFieldToBottom
                if shiftAmount > 0 {
                    scrollView.frame.origin.y -= shiftAmount
                }
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        if (scrollView.frame.origin.y != scrollViewOrigin!.y){
            scrollView.frame.origin.y = scrollViewOrigin!.y
        }
    }
    
}
