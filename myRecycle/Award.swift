//
//  Award.swift
//  myRecycle
//
//  Created by Ben LOWRY on 5/18/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

import Foundation
import UIKit

class Award: NSObject, NSCoding {
    
    var title: String = ""
    var pointWorth: Int = 0
    
    var image: UIImage = UIImage()
    
    required init?;?(coder aDecoder: NSCoder){
        title = aDecoder.decodeObjectForKey("Title") as! String
        pointWorth = aDecoder.decodeObjectForKey("Point Worth") as! Int
        
        image = aDecoder.decodeObjectForKey("Image") as! UIImage
        
        super.init()
    }
    
    init(title: String, pointWorth: Int, image: UIImage) {
        
        self.title = title
        self.pointWorth = pointWorth
        
        self.image = image
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "Title")
        aCoder.encodeObject(pointWorth, forKey: "Point Worth")
        
        aCoder.encodeObject(image, forKey: "Image")
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? Award {
            return self.title == other.title
        } else {
            return false
        }
    }
    
    
}