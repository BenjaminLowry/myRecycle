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
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).appendingPathComponent("LocalData.plist")
    }
    
    func saveLocalData() {
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(localAccounts, forKey: "LocalAccounts")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
        
    }
    
    func loadLocalData() {
        
        let path = dataFilePath()
        
        if FileManager.default.fileExists(atPath: path){
            
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                localAccounts = unarchiver.decodeObject(forKey: "LocalAccounts") as! [UserProfile]
                
                unarchiver.finishDecoding()
                
            }
            
        }
        
    }
    
}
