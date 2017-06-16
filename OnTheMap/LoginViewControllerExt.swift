//
//  LoginViewControllerExt.swift
//  OnTheMap
//
//  Created by Alexander on 5/10/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

extension LoginViewController : UITextFieldDelegate {
    
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
                var textField: UITextField? = nil
                if (txtEmail.isFirstResponder){
                    textField = txtEmail
                }
                else if (txtPassword.isFirstResponder){
                    textField = txtPassword
                }
                if textField != nil {
                    textFieldBottomY = textField!.frame.origin.y +
                                       textField!.frame.height
                }
                else {
                    return
                }
                
                // Difference between textFieldBottom and Bottom of the Screen
                let textFieldToBottom = screenHeight - textFieldBottomY
                
                // Shift screen up on the difference between keyboard height and textFieldToBottom
                let shiftAmount = keyboardHeight - textFieldToBottom
                if shiftAmount > 0 {
                    containerView.frame.origin.y -= shiftAmount + 10
                }
            }
        }
    
    }
    
    func keyboardWillHide(notification: NSNotification){
        containerView.frame.origin.y = 0
    }
    
}
