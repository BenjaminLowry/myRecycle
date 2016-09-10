//
//  AppDelegate.swift
//  myRecycle
//
//  Created by Ben LOWRY on 3/9/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //initialize Parse
        Parse.initializeWithConfiguration(ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
            configuration.server = "https://myrecycle.herokuapp.com/parse"
            configuration.applicationId = "myRecycle"
            configuration.clientKey = "BenjaminPaulLowry.AppDev"
        }))
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        saveData()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        saveData()
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("AppInfo.plist")
    }
    
    func saveData() {
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(currentAppStatus.loggedInUser, forKey: "Logged In User")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
        
        //upload data to Parse Servers / Heroku
        for index in currentAppStatus.localAccounts {
            
            let user = PFObject(className: "User")
            user.setObject(index.username, forKey: "Username")
            user.setObject(index.password, forKey: "Password")
            user.setObject(index.points, forKey: "Points")
            user.setObject(index.level, forKey: "Level")
            user.setObject(index.rank, forKey: "Rank")
            
            PFUser.currentUser()?.setObject(index.profilePicture, forKey: "Profile Picture")
            
            //user.setObject(index.profilePicture, forKey: "Profile Picture")
            
            user.setObject(index.carbonDioxideEmissionsPrevented, forKey: "CO2 Prevented")
            user.setObject(index.electricitySaved, forKey: "Electricity Saved")
            user.setObject(index.heartsWarmed, forKey: "Hearts Warmed")
            user.setObject(index.trashRecycled, forKey: "Trash Recycled")
            user.setObject(index.treesSaved, forKey: "Trees Saved")
            
            user.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                if succeeded {
                    print("Object Uploaded")
                } else {
                    print("Error: \(error) \(error!.userInfo)")
                }
            }
            
        }
        
        
    }


}

