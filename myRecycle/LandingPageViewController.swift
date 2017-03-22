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
        
        NotificationCenter.default.addObserver(self, selector: #selector(LandingPageViewController.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.hideKeyboardWhenTappedAround()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if currentAppStatus.loggedIn {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        initiateBorders([usernameView, passwordView, loginView, createAccountView])
        
    }
    
    @IBAction func login(_ sender: AnyObject){
    
        loadData()
        
        do {
            
            if localUsernames.contains(usernameTextField.text!){
                
                let accounts = currentAppStatus.localAccounts
                for index in accounts {
                    
                    if index.username == usernameTextField.text! {
                        
                        if index.password == passwordTextField.text! {
                            currentAppStatus.loggedIn = true
                            currentAppStatus.loggedInUser = index
                            self.dismiss(animated: true, completion: nil)
                        } else { //if the password doesn't match the username
                            throw AppError.loginError
                        }
                        
                    }
                    
                }
                
            } else { //if the inputted username is invalid
                throw AppError.loginError
            }
            
        } catch AppError.loginError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E07", message: "Login error, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        } catch {
            
            //present error
            let alertController = UIAlertController(title: "Error", message: "Sorry about that, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //keyboardWillChange (below) is used instead of textFieldDidBeginEditing because textFieldDidBeginEditing
        //is called before the UIKeyboardWillShowNotification necessary to determine the keyboard height.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateTextField(false)
    }
    
    
    func animateTextField(_ textFieldUp:Bool) {
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
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func keyboardWillChange(_ notification:Notification) {
        let keyboardRect:CGRect = (((notification.userInfo![UIKeyboardFrameEndUserInfoKey]) as AnyObject).cgRectValue)!
        keyboardHeight = keyboardRect.height
        animateTextField(true)
    }
    
    func sendLoginError(){
        
        let alert = UIAlertController(title: "Login Error", message: "Username and password do not match", preferredStyle: UIAlertControllerStyle.alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).appendingPathComponent("AccountInfo.plist")
    }
    
    func loadData() {
        let path = dataFilePath()
        
        if FileManager.default.fileExists(atPath: path){
            
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                localUsernames = unarchiver.decodeObject(forKey: "Usernames") as! [String]
                
                unarchiver.finishDecoding()
            }
            
        }
    }
    
    func initiateBorders(_ views: [UIView]) {
        
        for index: UIView in views {
            
            index.layer.borderWidth = 0.5
            
        }
        
    }
    
}
