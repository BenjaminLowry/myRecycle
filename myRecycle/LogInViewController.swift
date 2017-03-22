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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: AnyObject) {
        loadData()
        
        if localUsernames.contains(usernameTextField.text!){
            
            let accounts = currentAppStatus.localAccounts
            for index in accounts {
                
                if index.username == usernameTextField.text! {
                    
                    if index.password == passwordTextField.text! {
                        currentAppStatus.loggedIn = true
                        currentAppStatus.loggedInUser = index
                        self.dismiss(animated: true, completion: nil)
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
    
    
}
