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
    var uid : NSString? {
        get{
            return self.uid
        }
        set{
            if (newValue is NSString!) {
                self.uid = newValue
            }
        }
    }
    
    /** The unit uid. */
    var name : NSString?{
        get{
            return self.name
        }
        set{
            if (newValue is NSString!) {
                self.name = newValue
            }
        }
    }
    
    /** The type uid. */
    var type : NSString?{
        get{
            return self.type
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
    
    /** The room that this device/component is in. */
    var room : FGRoom? = nil
    
    /** Creates a new sort descriptor by uid, ascending. */
    private func sortDescriptor() ->NSSortDescriptor {
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "uid", ascending: true)
        //var sortedResults: NSArray = sortedArrayUsingDescriptors([descriptor])
        return descriptor
    }
    
    /** Creates a new sort descriptor by uid, ascending. */
    class func sortDescriptorsByUID() -> [Any] {
        return [NSSortDescriptor(key: "uid", ascending: true)]
    }
    
    /*public func getType()->NSString{
        return type!
    }*/
    
    override var description : String {
        return "[<\(NSStringFromClass(self.self as! AnyClass))> type:\(self.type) uid:\(self.uid) name:\(self.name)]"
    }
    
    
    override func isEqual(_ object: Any?) -> Bool {
        if !(object is FGControllableBase) {
            return false
        }
        return (self.uid == (object as! FGControllableBase).uid) && (self.type == (object as! FGControllableBase).type)
    }
    
    func getType() -> String? {
        // silent the warning
        return nil
    }
    
}
