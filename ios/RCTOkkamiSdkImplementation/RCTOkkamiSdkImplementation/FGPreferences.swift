//
//  FGPreferences.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGPreferences: NSObject {
    /** For use by FGPresets to parse mood objects.
     @param dict NSDictionary object from the preferences API.
     @returns FGPreferences object.
     */
    convenience init(dictionary dict: [AnyHashable: Any]) {
        self.init()
        var p = FGPreferences()
        
    }
}
