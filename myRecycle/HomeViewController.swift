//
//  ViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 3/9/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING


import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

enum AppError: ErrorType {
    case NilError //#E01
    case CellNotFoundError //#E02
    case ImageNotFoundError //#E03
    case NumberParseError //#E04
    case PasswordMismatchError //#E05
    case UsernameTakenError //#E06
    case LoginError //#E07
    case DecodeError //#E08
}

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var myLogLabel: UILabel!
    @IBOutlet weak var myStatsLabel: UILabel!
    @IBOutlet weak var myProfileLabel: UILabel!

    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        
        setLabelFonts([myLogLabel, myStatsLabel, myProfileLabel], font: UIFont(name: "AvenirNext-Medium", size: 50)!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAppStatus.loadLocalData()
        loadData()
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if currentAppStatus.loggedIn {
            
            if let text = currentAppStatus.loggedInUser?.username {
                
                welcomeLabel.text = "Welcome " + text + "!"
                welcomeLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 30)
                welcomeLabel.adjustsFontSizeToFitWidth = true
                welcomeLabel.baselineAdjustment = .AlignCenters
                welcomeLabel.textAlignment = NSTextAlignment.Center
                welcomeLabel.hidden = false
                
            }
            
            
            
        } else { //if no one is logged in
            
            welcomeLabel.hidden = true
            
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if !currentAppStatus.loggedIn {
            
            self.performSegueWithIdentifier("LandingPageSegue", sender: self)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileButtonPressed(sender: AnyObject) {
        
        if currentAppStatus.loggedIn {
            self.performSegueWithIdentifier("ProfileSegue", sender: self)
        } else {
            sendLoginNudge()
        }
        
    }
    
    @IBAction func logButtonPressed(sender: AnyObject){
        
        if currentAppStatus.loggedIn {
            self.performSegueWithIdentifier("LogSegue", sender: self)
        } else {
            sendLoginNudge()
        }
        
    }
    
    @IBAction func statsButtonPressed(sender: AnyObject) {
        
        if currentAppStatus.loggedIn {
            self.performSegueWithIdentifier("StatsSegue", sender: self)
        } else {
            sendLoginNudge()
        }
        
    }
    
    func sendLoginNudge() {
        
        let alert = UIAlertController(title: "Login Required", message: "Sorry, you need to login first", preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(alertAction)
        
        self.showViewController(alert, sender: self)
        
    }
    
    
    func setLabelFonts(labels: [UILabel], font: UIFont){
        
        for index in 0..<labels.count {
            
            labels[index].font = font
            labels[index].adjustsFontSizeToFitWidth = true
            labels[index].baselineAdjustment = .AlignCenters
            
        }
        
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("AppInfo.plist")
    }
    
    func loadData() {
        let path = dataFilePath()
        
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            
            if let data = NSData(contentsOfFile: path){
                
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                currentAppStatus.loggedInUser = unarchiver.decodeObjectForKey("Logged In User") as? UserProfile
                
                if currentAppStatus.loggedInUser != nil {
                    
                    currentAppStatus.loggedIn = true
                    
                }
                
                unarchiver.finishDecoding()
            }
            
        }
    }
    

}

