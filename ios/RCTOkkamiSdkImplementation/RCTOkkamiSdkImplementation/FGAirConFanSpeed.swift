//
//  FGAirConFanSpeed.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGAirConFanSpeed: FGObject {
    /** Title for display */
    var title: String = ""
    /** The command name string to construct a full command. e.g. the "HIGH" part of "FAN ac-1 HIGH" */
    var command: String = ""
    /** Whether this fan speed will also send a power off command after sending fan speed.
     Default is NO. */
    var isPowerOff: Bool = false
    
    func object(withDictionary dict: [AnyHashable: Any]) -> FGAirConFanSpeed {
        let obj = FGAirConFanSpeed()
        obj.title = dict["title"] as! String
        obj.command = dict["command"] as! String
        obj.isPowerOff = dict["poweroff"] as! Bool
        return obj
    }
    // MARK: - equality
    
    func isEqual(toObject object: FGAirConFanSpeed) -> Bool {
        return (self.title == object.title) && (self.command == object.command)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if self == (object as! FGAirConFanSpeed) {
            return true
        }
        return self.isEqual(toObject: (object as? FGAirConFanSpeed)!)
    }
    
    override var hash: Int{
        get{
            return self.title.hash ^ self.command.hash
        }
    }
}
