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
        
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        passwordCheckTextField.autocorrectionType = .no
    }
    
    @IBAction func done() {
        
        do {
        
            if passwordTextField.text! != passwordCheckTextField.text! {
                
                throw AppError.passwordMismatchError
                
            } else if localUsernames.contains(usernameTextField.text!) {
                
                throw AppError.usernameTakenError
                
            } else {
                
                if usernameTextField.text != nil && passwordTextField.text != nil {
                    
                    let newAccount = UserProfile(username: usernameTextField.text!, password: passwordTextField.text!)
                    localUsernames.append(usernameTextField.text!)
                    currentAppStatus.localAccounts.append(newAccount)
                    currentAppStatus.saveLocalData()
                    saveData()
                    
                    currentAppStatus.loggedIn = true
                    currentAppStatus.loggedInUser = newAccount
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    
                    throw AppError.nilError
                    
                }
                
            }
            
        } catch AppError.passwordMismatchError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E05", message: "Passwords do not match, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        } catch AppError.usernameTakenError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E06", message: "Username is taken, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        } catch AppError.nilError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E01", message: "One or more fields are empty, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        } catch {
            
            //present error
            let alertController = UIAlertController(title: "Error", message: "One or more fields are empty, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).appendingPathComponent("AccountInfo.plist")
    }
    
    func saveData() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(localUsernames, forKey: "Usernames")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
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
