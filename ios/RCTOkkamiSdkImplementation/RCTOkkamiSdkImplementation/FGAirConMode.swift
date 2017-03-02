//
//  FGAirConMode.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation

class FGAirConMode: FGObject {
    /** Title for display */
    var title: String = ""
    /** String to construct a full command. e.g. the "COOLING" part of "MODE ac-1 COOLING" */
    var command: String = ""
    
    func object(withDictionary dict: [AnyHashable: Any]) -> FGAirConMode {
        let obj = FGAirConMode()
        obj.title = dict["title"] as! String
        obj.command = dict["command"] as! String
        return obj 
    }
    // MARK: - equality
    
    func isEqual(toObject object: FGAirConMode) -> Bool {
        return (self.title == object.title) && (self.command == object.command)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as! FGAirConMode){
            return true
        }
        return self.isEqual(toObject: (object as? FGAirConMode)!)
    }
    
    override var hash: Int{
        get{
            return self.title.hash ^ self.command.hash
        }
    }
}
