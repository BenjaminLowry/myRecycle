//
//  LogInViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 5/3/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

import Foundation
import UIKit

class LogInViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var localUsernames: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        loadData()
        
        if localUsernames.contains(usernameTextField.text!){
            
            let accounts = currentAppStatus.localAccounts
            for index in accounts {
                
                if index.username == usernameTextField.text! {
                    
                    if index.password == passwordTextField.text! {
                        currentAppStatus.loggedIn = true
                        currentAppStatus.loggedInUser = index
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else { //if the password doesn't match the username
                        sendLoginError()
                    }
                    
                }
                
            }
            
        } else { //if the inputted username is invalid
            sendLoginError()
        }
        
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
    
    
}