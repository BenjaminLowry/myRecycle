//
//  AppStatus.swift
//  myRecycle
//
//  Created by Ben LOWRY on 5/5/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation

var currentAppStatus: AppStatus = AppStatus()

class AppStatus {
    
    var loggedIn: Bool = false
    var loggedInUser: UserProfile?
    
    var localAccounts: [UserProfile] = [UserProfile]()
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("LocalData.plist")
    }
    
    func saveLocalData() {
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(localAccounts, forKey: "LocalAccounts")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
        
    }
    
    func loadLocalData() {
        
        let path = dataFilePath()
        
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            
            if let data = NSData(contentsOfFile: path){
                
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                localAccounts = unarchiver.decodeObjectForKey("LocalAccounts") as! [UserProfile]
                
                unarchiver.finishDecoding()
                
            }
            
        }
        
    }
    
}