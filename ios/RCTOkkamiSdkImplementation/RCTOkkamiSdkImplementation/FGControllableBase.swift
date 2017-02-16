//
//  FGControllableBase.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class FGControllableBase: NSObject {
    
    /** The unit uid. Contains either `device_uid` or `component_uid` from room data.*/
    var uid : NSString = ""
    
    /** The unit uid. */
    var name : NSString = ""
    
    /** The type uid. */
    var type : NSString = ""
    
    /** The room that this device/component is in. */
    var room : FGRoom? = nil
    
    /** Creates a new sort descriptor by uid, ascending. */
    private func sortDescriptor() ->NSSortDescriptor {
        var descriptor: NSSortDescriptor = NSSortDescriptor(key: "uid", ascending: true)
        //var sortedResults: NSArray = sortedArrayUsingDescriptors([descriptor])
        return descriptor
    }
    
    public func getType()->NSString{
        return type
    }
}
