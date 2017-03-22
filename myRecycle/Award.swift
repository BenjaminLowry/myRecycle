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
    
    required init?(coder aDecoder: NSCoder){
        title = aDecoder.decodeObject(forKey: "Title") as! String
        pointWorth = aDecoder.decodeObject(forKey: "Point Worth") as! Int
        
        image = aDecoder.decodeObject(forKey: "Image") as! UIImage
        
        super.init()
    }
    
    init(title: String, pointWorth: Int, image: UIImage) {
        
        self.title = title
        self.pointWorth = pointWorth
        
        self.image = image
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "Title")
        aCoder.encode(pointWorth, forKey: "Point Worth")
        
        aCoder.encode(image, forKey: "Image")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Award {
            return self.title == other.title
        } else {
            return false
        }
    }
    
    
}
