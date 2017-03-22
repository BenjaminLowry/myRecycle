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

enum AppError: Error {
    case nilError //#E01
    case cellNotFoundError //#E02
    case imageNotFoundError //#E03
    case numberParseError //#E04
    case passwordMismatchError //#E05
    case usernameTakenError //#E06
    case loginError //#E07
    case decodeError //#E08
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if currentAppStatus.loggedIn {
            
            if let text = currentAppStatus.loggedInUser?.username {
                
                welcomeLabel.text = "Welcome " + text + "!"
                welcomeLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 30)
                welcomeLabel.adjustsFontSizeToFitWidth = true
                welcomeLabel.baselineAdjustment = .alignCenters
                welcomeLabel.textAlignment = NSTextAlignment.center
                welcomeLabel.isHidden = false
                
            }
            
            
            
        } else { //if no one is logged in
            
            welcomeLabel.isHidden = true
            
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if !currentAppStatus.loggedIn {
            
            self.performSegue(withIdentifier: "LandingPageSegue", sender: self)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileButtonPressed(_ sender: AnyObject) {
        
        if currentAppStatus.loggedIn {
            self.performSegue(withIdentifier: "ProfileSegue", sender: self)
        } else {
            sendLoginNudge()
        }
        
    }
    
    @IBAction func logButtonPressed(_ sender: AnyObject){
        
        if currentAppStatus.loggedIn {
            self.performSegue(withIdentifier: "LogSegue", sender: self)
        } else {
            sendLoginNudge()
        }
        
    }
    
    @IBAction func statsButtonPressed(_ sender: AnyObject) {
        
        if currentAppStatus.loggedIn {
            self.performSegue(withIdentifier: "StatsSegue", sender: self)
        } else {
            sendLoginNudge()
        }
        
    }
    
    func sendLoginNudge() {
        
        let alert = UIAlertController(title: "Login Required", message: "Sorry, you need to login first", preferredStyle: UIAlertControllerStyle.alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(alertAction)
        
        self.show(alert, sender: self)
        
    }
    
    
    func setLabelFonts(_ labels: [UILabel], font: UIFont){
        
        for index in 0..<labels.count {
            
            labels[index].font = font
            labels[index].adjustsFontSizeToFitWidth = true
            labels[index].baselineAdjustment = .alignCenters
            
        }
        
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).appendingPathComponent("AppInfo.plist")
    }
    
    func loadData() {
        let path = dataFilePath()
        
        if FileManager.default.fileExists(atPath: path){
            
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                currentAppStatus.loggedInUser = unarchiver.decodeObject(forKey: "Logged In User") as? UserProfile
                
                if currentAppStatus.loggedInUser != nil {
                    
                    currentAppStatus.loggedIn = true
                    
                }
                
                unarchiver.finishDecoding()
            }
            
        }
    }
    

}

