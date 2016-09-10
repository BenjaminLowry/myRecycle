//
//  UserProfile.swift
//  myRecycle
//
//  Created by Ben LOWRY on 3/9/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation
import UIKit

class UserProfile: NSObject, NSCoding {
    
    var username: String = ""
    var password: String = ""
    var points: Int = 0
    var level: Int = 1
    var rank: String = "Private"
    
    var logItems: [LogItem] = []
    
    var treesSaved: Double = 0.00
    var carbonDioxideEmissionsPrevented: Double = 0.00 //in kilograms
    var electricitySaved: Double = 0.00 //in kWh (?)
    var waterSaved: Double = 0.00 //in liters
    var trashRecycled: Double = 0.00 //in kilograms
    var heartsWarmed: Int = 0
    
    var profilePicture: UIImage = UIImage(named: "Temporary Profile Photo")!
    
    init(username: String, password: String){
        
        self.username = username
        self.password = password
        
    }
    
    required init?(coder aDecoder: NSCoder){
        
        do {
            
            if aDecoder.decodeObjectForKey("Username") != nil && aDecoder.decodeObjectForKey("Password") != nil && aDecoder.decodeObjectForKey("Points") != nil && aDecoder.decodeObjectForKey("Level") != nil && aDecoder.decodeObjectForKey("Rank") != nil  {
                
                username = aDecoder.decodeObjectForKey("Username") as! String
                password = aDecoder.decodeObjectForKey("Password") as! String
                points = aDecoder.decodeObjectForKey("Points") as! Int
                level = aDecoder.decodeObjectForKey("Level") as! Int
                rank = aDecoder.decodeObjectForKey("Rank") as! String
                
            } else {
                
                throw AppError.DecodeError
            }
            
            if aDecoder.decodeObjectForKey("Log Items") != nil {
                logItems = aDecoder.decodeObjectForKey("Log Items") as! [LogItem]
            } else {
                
                throw AppError.DecodeError
            }
            
            if aDecoder.decodeObjectForKey("Trees Saved") != nil && aDecoder.decodeObjectForKey("CO2 Prevented") != nil && aDecoder.decodeObjectForKey("Electricity Saved") != nil && aDecoder.decodeObjectForKey("Water Saved") != nil && aDecoder.decodeObjectForKey("Hearts Warmed") != nil {
                
                treesSaved = aDecoder.decodeObjectForKey("Trees Saved") as! Double
                carbonDioxideEmissionsPrevented = aDecoder.decodeObjectForKey("CO2 Prevented") as! Double
                electricitySaved = aDecoder.decodeObjectForKey("Electricity Saved") as! Double
                waterSaved = aDecoder.decodeObjectForKey("Water Saved") as! Double
                trashRecycled = aDecoder.decodeObjectForKey("Trees Recycled") as! Double
                heartsWarmed = aDecoder.decodeObjectForKey("Hearts Warmed") as! Int
                
            } else {
                
                throw AppError.DecodeError
            }
            
            if aDecoder.decodeObjectForKey("Profile Picture") != nil {
                profilePicture = aDecoder.decodeObjectForKey("Profile Picture") as! UIImage
            } else {
                
                throw AppError.DecodeError
            }
            
        } catch AppError.DecodeError {
            
            print("decoding error")
            
        } catch {
            
            print("unknown error")
            
        }
        
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: "Username")
        aCoder.encodeObject(password, forKey: "Password")
        aCoder.encodeObject(points, forKey: "Points")
        aCoder.encodeObject(level, forKey: "Level")
        aCoder.encodeObject(rank, forKey: "Rank")
        
        aCoder.encodeObject(logItems, forKey: "Log Items")
        
        aCoder.encodeObject(treesSaved, forKey: "Trees Saved")
        aCoder.encodeObject(carbonDioxideEmissionsPrevented, forKey: "CO2 Prevented")
        aCoder.encodeObject(electricitySaved, forKey: "Electricity Saved")
        aCoder.encodeObject(waterSaved, forKey: "Water Saved")
        aCoder.encodeObject(trashRecycled, forKey: "Trees Recycled")
        aCoder.encodeObject(heartsWarmed, forKey: "Hearts Warmed")
        
        aCoder.encodeObject(profilePicture, forKey: "Profile Picture")
        
    }
    
    func updateLevel() {
        
        var increaseValue = 2200
        var pointThreshold = -200 //-200 + 2200 will reach the first level of 2000
        var level: Int = 0
        
        while level < 500 {
            
            
            pointThreshold += increaseValue
            increaseValue += 200 //level gaps increase by 200 points each time
           
            if points < pointThreshold {
                break
            }
            
            level += 1
        }
        
        self.level = level + 1
        
    }
    
    func updateRank() {
        
        switch level {
        case let x where x < 5:
            rank = "Private"
        case let x where x < 10:
            rank = "Common Joe"
        case let x where x < 15:
            rank = "Amateur Recycler"
        case let x where x < 20:
            rank = "Tree Hugger"
        case let x where x < 25:
            rank = "Frequent Recycler"
        case let x where x < 30:
            rank = "Recycling Enthusiast"
        case let x where x < 35:
            rank = "Experienced Recycler"
        case let x where x < 40:
            rank = "Elite Reclaimer"
        case let x where x < 45:
            rank = "Prestigious Recycler"
        case let x where x < 50:
            rank = "Advanced Salvager"
        case let x where x < 55:
            rank = "Recycling Expert"
        case let x where x < 60:
            rank = "Master Recycler"
        case let x where x < 65:
            rank = "Ozone Saviour"
        case let x where x < 70:
            rank = "Professional Recycler"
        case let x where x < 75:
            rank = "Trask Killer"
        case let x where x < 80:
            rank = "Magical Recycler"
        case let x where x < 85:
            rank = "Recycling Legend"
        case let x where x < 90:
            rank = "Savior of Hong Kong"
        case let x where x < 95:
            rank = "Recycling God"
        case let x where x < 100:
            rank = "Earth Saver"
        default:
            rank = "Universe Saver"
        }
        
    }
    
    func updateStats(materialType: String, unit: String, amount: Double, reducingStats: Bool) -> [Double]{
        
        //to establish previous values in order to calculate change
        let previousElectricity: Double = (currentAppStatus.loggedInUser?.electricitySaved)!
        let previousWater: Double = (currentAppStatus.loggedInUser?.waterSaved)!
        let previousTrees: Double = (currentAppStatus.loggedInUser?.treesSaved)!
        let previousCO2: Double = (currentAppStatus.loggedInUser?.carbonDioxideEmissionsPrevented)!
        let previousTrash: Double = (currentAppStatus.loggedInUser?.trashRecycled)!
        
        //calculation variables initialized
        let gramsInAPound = 453.592
        
        let aluminumCanWeightInGrams = 14.90
        let aluminumCO2Ratio = (1.00, 5.00) //any weight
        let aluminumElectricityRatio = (1.00, 15.43) //kg to kWh
        
        let cardboardElectricityRatio = (1.00, 0.43) //kg to kWh
        
        let foodWasteCO2Ratio = (1.00, 2.54) //any weight
        let foodWasteWaterRatio = (1.00, 196.57) //kg to liters
        
        let glassBottleWeightInGrams = 551.00
        let glassCO2Ratio = (1.00, 0.34)
        let glassElectricityRatio = (1.00, 0.05) //kg to kWh
        
        let paperWeightInGrams = 4.536
        let paperElectricityRatio = (1.00, 4.51) //kg to kWh
        let paperWaterRatio = (1.00, 29.22) //kg to liters
        
        let plasticBagWeightInGrams = 5.50
        
        let plasticBottleWeightInGrams = 12.70
        let plasticBottleCO2Ratio = (1.00, 1.70) //any weight
        let plasticBottleElectricityRatio = (1.00, 6.36) //kg to kWh
        
        let plasticPackagingCO2Ratio = (1.00, 1.30)
        
        //variable for adding/subtracting stats
        var multiplier: Double = 1
        
        if reducingStats {
            multiplier = -1
        }
        
        switch materialType {
        case "Aluminum Cans":
            switch unit {
            case "Cans":
                carbonDioxideEmissionsPrevented += ((amount * aluminumCanWeightInGrams * multiplier) * aluminumCO2Ratio.1) / 1000
                electricitySaved += ((amount * aluminumCanWeightInGrams * multiplier) * aluminumElectricityRatio.1) / 1000
                trashRecycled += (amount * aluminumCanWeightInGrams * multiplier) / 1000
            case "Pounds":
                carbonDioxideEmissionsPrevented += ((amount * gramsInAPound * multiplier) * aluminumCO2Ratio.1) / 1000
                electricitySaved += ((amount * gramsInAPound * multiplier) * aluminumElectricityRatio.1) / 1000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                carbonDioxideEmissionsPrevented += amount * aluminumCO2Ratio.1 * multiplier
                electricitySaved += amount * aluminumElectricityRatio.1 * multiplier
                trashRecycled += amount * multiplier
            default:
                break
            }
        case "Cardboard":
            switch unit {
            case "Pounds":
                electricitySaved += ((amount * gramsInAPound * multiplier) * cardboardElectricityRatio.1) / 1000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                electricitySaved += amount * cardboardElectricityRatio.1 * multiplier
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        case "Electronics":
            switch unit {
            case "Pounds":
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                trashRecycled += amount * multiplier
            default:
                break
            }
         
        case "Food Waste":
            switch unit {
            case "Pounds":
                carbonDioxideEmissionsPrevented += ((amount * gramsInAPound * multiplier) * foodWasteCO2Ratio.1) / 1000
                waterSaved += ((amount * gramsInAPound * multiplier) * foodWasteWaterRatio.1) / 1000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                carbonDioxideEmissionsPrevented += amount * foodWasteCO2Ratio.1 * multiplier
                waterSaved += amount * foodWasteWaterRatio.1 * multiplier
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        case "Glass":
            switch unit {
            case "Bottles":
                carbonDioxideEmissionsPrevented += ((amount * glassBottleWeightInGrams * multiplier) * glassCO2Ratio.1) / 1000
                electricitySaved += ((amount * glassBottleWeightInGrams * multiplier) * glassElectricityRatio.1) / 1000
                trashRecycled += (amount * glassBottleWeightInGrams * multiplier) / 1000
            case "Pounds":
                carbonDioxideEmissionsPrevented += ((amount * gramsInAPound * multiplier) * glassCO2Ratio.1) / 1000
                electricitySaved += ((amount * gramsInAPound * multiplier) * glassElectricityRatio.1) / 1000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                carbonDioxideEmissionsPrevented += amount * glassCO2Ratio.1 * multiplier
                electricitySaved += amount * glassElectricityRatio.1 * multiplier
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        case "Paper":
            switch unit {
            case "Pages":
                electricitySaved += ((amount * paperWeightInGrams * multiplier) * paperElectricityRatio.1) / 1000
                waterSaved += ((amount * paperWeightInGrams * multiplier) * paperWaterRatio.1) / 1000
                treesSaved += amount * multiplier / 15000
                trashRecycled += (amount * paperWeightInGrams * multiplier) / 1000
            case "Pounds":
                electricitySaved += ((amount * gramsInAPound * multiplier) * paperElectricityRatio.1) / 1000
                waterSaved += ((amount * gramsInAPound * multiplier) * paperWaterRatio.1) / 1000
                treesSaved += ((amount * gramsInAPound * multiplier) / paperWeightInGrams) / 15000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                electricitySaved += amount * paperElectricityRatio.1 * multiplier
                waterSaved += amount * paperWaterRatio.1 * multiplier
                treesSaved += ((amount * 1000 * multiplier) / paperWeightInGrams) / 15000
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        case "Plastic Bags":
            switch unit {
            case "Bags":
                carbonDioxideEmissionsPrevented += ((amount * plasticBagWeightInGrams * multiplier) * plasticPackagingCO2Ratio.1) / 1000
                trashRecycled += (amount * plasticBagWeightInGrams * multiplier) / 1000
            case "Pounds":
                carbonDioxideEmissionsPrevented += ((amount * gramsInAPound * multiplier) * plasticPackagingCO2Ratio.1) / 1000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                carbonDioxideEmissionsPrevented += amount * plasticPackagingCO2Ratio.1 * multiplier
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        case "Plastic Bottles":
            switch unit {
            case "Bottles":
                carbonDioxideEmissionsPrevented += ((amount * plasticBottleWeightInGrams * multiplier) * plasticBottleCO2Ratio.1) / 1000
                electricitySaved += ((amount * plasticBottleWeightInGrams * multiplier) * plasticBottleElectricityRatio.1) / 1000
                trashRecycled += (amount * plasticBottleWeightInGrams * multiplier) / 1000
            case "Pounds":
                carbonDioxideEmissionsPrevented += ((amount * gramsInAPound * multiplier) * plasticBottleCO2Ratio.1) / 1000
                electricitySaved += ((amount * gramsInAPound * multiplier) * plasticBottleElectricityRatio.1) / 1000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                carbonDioxideEmissionsPrevented += amount * plasticBottleCO2Ratio.1 * multiplier
                carbonDioxideEmissionsPrevented += amount * plasticBottleElectricityRatio.1 * multiplier
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        case "Plastic Packaging":
            switch unit {
            case "Pounds":
                carbonDioxideEmissionsPrevented += ((amount * gramsInAPound * multiplier) * plasticPackagingCO2Ratio.1) / 1000
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                carbonDioxideEmissionsPrevented += amount * plasticPackagingCO2Ratio.1 * multiplier
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        case "Rubber":
            switch unit {
            case "Pounds":
                trashRecycled += (amount * gramsInAPound * multiplier) / 1000
            case "Kilograms":
                trashRecycled += amount * multiplier
            default:
                break
            }
            
        default:
            break
        }
        
        //return values
        var returnArray: [Double] = []
        
        returnArray.append((currentAppStatus.loggedInUser?.electricitySaved)! - previousElectricity) //electricity
        returnArray.append((currentAppStatus.loggedInUser?.waterSaved)! - previousWater) //water
        returnArray.append((currentAppStatus.loggedInUser?.treesSaved)! - previousTrees) //trees
        returnArray.append((currentAppStatus.loggedInUser?.carbonDioxideEmissionsPrevented)! - previousCO2) //CO2
        returnArray.append((currentAppStatus.loggedInUser?.trashRecycled)! - previousTrash)
        
        return returnArray
        
    }
    
    func determineProgress() -> (Int,Int) {
        
        var increaseValue = 2200
        var pointThreshold = -200 //-200 + 2200 will reach the first level of 2000
        
        var progress: (Int,Int) = (0,0)
        
        for _ in 1  ..< 500  {
            
            pointThreshold += increaseValue
            increaseValue += 200 //level gaps increase by 200 points each time
            
            if points < pointThreshold { //this pointThreshold is going to be for the next level
                if pointThreshold == 2000 { //only for the first level
                    progress.0 = points
                    progress.1 = 2000
                } else {
                    let previousLevelThreshold = pointThreshold - (increaseValue - 200)
                    progress.0 = points - previousLevelThreshold
                    progress.1 = pointThreshold - previousLevelThreshold
                }
                break
            }
        }
        
        return progress
        
        
    }
    
}