//
//  FGIconDictObject.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGIconDictObject: FGObject {
    /** Built in icon name */
    var iconName: String = ""
    /** Built-in icons. Override this to provide images for a particular `iconName`. */
    var defaultIcon : UIImage?{
        get{
            return self.defaultIcon
        }set{
            self.defaultIcon = newValue
        }
    }
    
    var icon : UIImage{
        get{
            var icon: UIImage?
            icon = (self.self.iconDictExtra?[self.iconName] as? UIImage)
            if icon != nil {
                return icon!
            }
            icon = (self.self.iconDictBuiltIn?[self.iconName] as? UIImage)
            if icon != nil {
                return icon!
            }
            return self.self.defaultIcon!

        }
        set{
            self.icon = newValue
        }
    }
    var iconDictBuiltIn: [AnyHashable: Any]?
    
    var iconDictExtra: [AnyHashable: Any]?{
        get{
            return self.iconDictExtra
        }set{
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if (newValue! is [AnyHashable: Any]) {
                    self.iconDictExtra = newValue
                }
            }
        }
    }
    
}
