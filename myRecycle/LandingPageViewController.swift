//
//  LandingPageViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 5/23/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation
import UIKit

class LandingPageViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var createAccountView: UIView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var localUsernames: [String] = [String]()
    
    var keyboardHeight:CGFloat = 0
    
    override func viewDidLoad() {
        
        loadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LandingPageViewController.keyboardWillChange(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        usernameTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if currentAppStatus.loggedIn {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        initiateBorders([usernameView, passwordView, loginView, createAccountView])
        
    }
    
    @IBAction func login(sender: AnyObject){
    
        loadData()
        
        do {
            
            if localUsernames.contains(usernameTextField.text!){
                
                let accounts = currentAppStatus.localAccounts
                for index in accounts {
                    
                    if index.username == usernameTextField.text! {
                        
                        if index.password == passwordTextField.text! {
                            currentAppStatus.loggedIn = true
                            currentAppStatus.loggedInUser = index
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else { //if the password doesn't match the username
                            throw AppError.LoginError
                        }
                        
                    }
                    
                }
                
            } else { //if the inputted username is invalid
                throw AppError.LoginError
            }
            
        } catch AppError.LoginError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E07", message: "Login error, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } catch {
            
            //present error
            let alertController = UIAlertController(title: "Error", message: "Sorry about that, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //keyboardWillChange (below) is used instead of textFieldDidBeginEditing because textFieldDidBeginEditing
        //is called before the UIKeyboardWillShowNotification necessary to determine the keyboard height.
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateTextField(false)
    }
    
    
    func animateTextField(textFieldUp:Bool) {
        let movementDistance:CGFloat = keyboardHeight
        let movementDuration = 0.3
        
        var movement:CGFloat = 0
        
        if textFieldUp {
            movement = -movementDistance
        } else {
            movement = movementDistance
        }
        
        UIView.beginAnimations("anim", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    func keyboardWillChange(notification:NSNotification) {
        let keyboardRect:CGRect = ((notification.userInfo![UIKeyboardFrameEndUserInfoKey])?.CGRectValue)!
        keyboardHeight = keyboardRect.height
        animateTextField(true)
    }
    
    func sendLoginError(){
        
        let alert = UIAlertController(title: "Login Error", message: "Username and password do not match", preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("AccountInfo.plist")
    }
    
    func loadData() {
        let path = dataFilePath()
        
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            
            if let data = NSData(contentsOfFile: path){
                
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                localUsernames = unarchiver.decodeObjectForKey("Usernames") as! [String]
                
                unarchiver.finishDecoding()
            }
            
        }
    }
    
    func initiateBorders(views: [UIView]) {
        
        for index: UIView in views {
            
            index.layer.borderWidth = 0.5
            
        }
        
    }
    
}