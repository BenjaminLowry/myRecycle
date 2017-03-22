//
//  LogItem.swift
//  myRecycle
//
//  Created by Ben LOWRY on 4/26/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation

class LogItem: NSObject, NSCoding {
    var materialType: String = ""
    var amount: Double = 0
    var unit: String = ""
    
    var pointWorth: Int = 0
    
    init (materialType: String, amount: Double, unit: String){
        self.materialType = materialType
        self.amount = amount
        self.unit = unit
        
        super.init()
        
        determinePointWorth()
    }
    
    required init?(coder aDecoder: NSCoder){
        
        do {
            
            if aDecoder.decodeObject(forKey: "Material Type") != nil && aDecoder.decodeDouble(forKey: "Amount") != 0.0 && aDecoder.decodeObject(forKey: "Unit") != nil {
                
                materialType = aDecoder.decodeObject(forKey: "Material Type") as! String
                amount = aDecoder.decodeDouble(forKey: "Amount")
                unit = aDecoder.decodeObject(forKey: "Unit") as! String
                
            } else { //error from here
                
                throw AppError.decodeError
            }
            
            if aDecoder.decodeObject(forKey: "PointWorth") != nil {
                pointWorth = aDecoder.decodeObject(forKey: "PointWorth") as! Int
            } else {
               
                throw AppError.decodeError
            }
            
        } catch AppError.decodeError {
            print("decoding error")
        } catch {
            print("unknown error")
        }
        
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(materialType, forKey: "Material Type")
        aCoder.encode(amount, forKey: "Amount")
        aCoder.encode(unit, forKey: "Unit")
        
        aCoder.encode(pointWorth, forKey: "PointWorth")
    }
    
    func determinePointWorth() {
        
        let gramsInAPound = 453.592
        let poundsInAKilogram = 2.205
        
        let aluminumCanWeightInGrams = 14.9
        
        let glassBottleWeightInGrams = 551.0
        
        let paperWeightInGrams = 4.536
        
        let plasticBagWeightInGrams = 5.5
        
        let plasticBottleWeightInGrams = 12.7
        
        switch materialType {
        case "Aluminum Cans":
            switch unit {
            case "Cans":
                pointWorth = Int(round(100.0 * amount))
            case "Pounds":
                pointWorth = Int(round(100.0 * ((amount * gramsInAPound) / aluminumCanWeightInGrams)))
            case "Kilograms":
                pointWorth = Int(round(100.0 * ((amount * 1000) / aluminumCanWeightInGrams)))
            default:
                break
            }
        case "Cardboard":
            switch unit {
            case "Pounds":
                pointWorth = Int(round(140.0 * amount))
            case "Kilograms":
                pointWorth = Int(round(140.0 * (amount * poundsInAKilogram)))
            default:
                break
            }
            
        case "Electronics":
            switch unit {
            case "Smart Phones":
                pointWorth = Int(round(6000.0 * amount))
            case "MP3 Players":
                pointWorth = Int(round(1500.0 * amount))
            case "Laptops":
                pointWorth = Int(round(10000.0 * amount))
            case "Televisions":
                pointWorth = Int(round(12000.0 * amount))
            case "DVD Players":
                pointWorth = Int(round(6000.0 * amount))
            case "Pounds":
                pointWorth = Int(round(500.0 * amount))
            case "Kilograms":
                pointWorth = Int(round(500.0 * (amount * poundsInAKilogram)))
            default:
                break
            }
            
        case "Food Waste":
            switch unit {
            case "Pounds":
                pointWorth = Int(round(200.0 * amount))
            case "Kilograms":
                pointWorth = Int(round(200.0 * (amount * poundsInAKilogram)))
            default:
                break
            }
            
        case "Glass":
            switch unit {
            case "Bottles":
                pointWorth = Int(round(250.0 * amount))
            case "Pounds":
                pointWorth = Int(round(250.0 * ((amount * gramsInAPound) / glassBottleWeightInGrams)))
            case "Kilograms":
                pointWorth = Int(round(250.0 * ((amount * 1000) / glassBottleWeightInGrams)))
            default:
                break
            }
            
        case "Paper":
            switch unit {
            case "Pages":
                pointWorth = Int(round(5.0 * amount))
            case "Pounds":
                pointWorth = Int(round(5.0 * ((amount * gramsInAPound) / paperWeightInGrams)))
            case "Kilograms":
                pointWorth = Int(round(5.0 * ((amount * 1000) / paperWeightInGrams)))
            default:
                break
            }
            
        case "Plastic Bags":
            switch unit {
            case "Bags":
                pointWorth = Int(round(10.0 * amount))
            case "Pounds":
                pointWorth = Int(round(10.0 * ((amount * gramsInAPound) / plasticBagWeightInGrams)))
            case "Kilograms":
                pointWorth = Int(round(10.0 * ((amount * 1000) / plasticBagWeightInGrams)))
            default:
                break
            }
            
        case "Plastic Bottles":
            switch unit {
            case "Bottles":
                pointWorth = Int(round(15.0 * amount))
            case "Pounds":
                pointWorth = Int(round(15.0 * ((amount * gramsInAPound) / plasticBottleWeightInGrams)))
            case "Kilograms":
                pointWorth = Int(round(250.0 * ((amount * 1000) / plasticBottleWeightInGrams)))
            default:
                break
            }
            
        case "Plastic Packaging":
            switch unit {
            case "Pounds":
                pointWorth = Int(round(10.0 * amount))
            case "Kilograms":
                pointWorth = Int(round(10.0 * (amount * poundsInAKilogram)))
            default:
                break
            }
            
        case "Rubber":
            switch unit {
            case "Pounds":
                pointWorth = Int(round(60.0 * amount))
            case "Kilograms":
                pointWorth = Int(round(60.0 * (amount * poundsInAKilogram)))
            default:
                break
            }
        
        default:
            break
        }
        
    }
    
}
