//
//  CreateAccountViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 5/3/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation
import UIKit

class CreateAccountViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    
    var localUsernames: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        usernameTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No
        passwordCheckTextField.autocorrectionType = .No
    }
    
    @IBAction func done() {
        
        do {
        
            if passwordTextField.text! != passwordCheckTextField.text! {
                
                throw AppError.PasswordMismatchError
                
            } else if localUsernames.contains(usernameTextField.text!) {
                
                throw AppError.UsernameTakenError
                
            } else {
                
                if usernameTextField.text != nil && passwordTextField.text != nil {
                    
                    let newAccount = UserProfile(username: usernameTextField.text!, password: passwordTextField.text!)
                    localUsernames.append(usernameTextField.text!)
                    currentAppStatus.localAccounts.append(newAccount)
                    currentAppStatus.saveLocalData()
                    saveData()
                    
                    currentAppStatus.loggedIn = true
                    currentAppStatus.loggedInUser = newAccount
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    
                    throw AppError.NilError
                    
                }
                
            }
            
        } catch AppError.PasswordMismatchError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E05", message: "Passwords do not match, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } catch AppError.UsernameTakenError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E06", message: "Username is taken, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } catch AppError.NilError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E01", message: "One or more fields are empty, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } catch {
            
            //present error
            let alertController = UIAlertController(title: "Error", message: "One or more fields are empty, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("AccountInfo.plist")
    }
    
    func saveData() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(localUsernames, forKey: "Usernames")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
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