//
//  FGControllableGroups.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class FGDeviceGroup : NSObject {
    
    /** Group name */
    var name : NSString = ""
    
    /** Group FGDevice objects, sorted by uid in ascending order. */
    var devices : Array<FGDevice>? = nil
    
    /** Group FGDevice objects except FGDeviceGuest, sorted by uid in ascending order. */
    var nonGuestDevices : Array<FGDevice>? = nil
    
    private var deviceMutableArray : NSMutableArray?
    
    convenience required init(groupName: NSString){
        self.init()
        self.name = groupName as! NSString
        self.deviceMutableArray = []
    }
    
    private func deviceGroupWithName(name: NSString, devices: NSArray)->FGDeviceGroup{
        var newDeviceGroup = FGDeviceGroup(groupName: name)
        newDeviceGroup.addDevices(devices: devices)
        var arrDev = getDevices() as [FGDevice]
        self.devices?.append(contentsOf: arrDev)
        var arrNonGuestDev = getNonGuestDevices() as [FGDevice]
        self.nonGuestDevices?.append(contentsOf: arrNonGuestDev)
        return newDeviceGroup
    }
    
    private func addDevices(devices: NSArray){
        deviceMutableArray?.addObjects(from: devices as! [FGDevice])
    }
    
    private func addDevice(devices: FGDevice){
        self.devices?.append(devices)
        deviceMutableArray?.add(devices)
    }
    
    private func getDevices()->[FGDevice]{
        return NSArray(array: deviceMutableArray!) as! [FGDevice]
    }
    
    private func getNonGuestDevices()->[FGDevice]{
        let resultPredicate = NSPredicate(format: "type != %@", FGDeviceGuest().type())
        var arr = deviceMutableArray?.filtered(using: resultPredicate)
        return arr as! [FGDevice]
    }
    
}

class FGComponentGroup : NSObject{
    
    /** Group name */
    var name : NSString = ""
    
    /** Group FGDevice objects, sorted by uid in ascending order. */
    var components : Array<FGComponent>? = nil
    
    private var componentsMutableArray : NSMutableArray?
    
    convenience required init(groupName: NSString){
        self.init()
        self.name = groupName as! NSString
        self.componentsMutableArray = []
    }
    
    private func componentGroupWithName(name: NSString, devices: NSArray)->FGComponentGroup{
        var newComponentGroup = FGComponentGroup(groupName: name)
        newComponentGroup.addComponents(components: devices)
        var arrCom = getComponents() as [FGComponent]
        self.components?.append(contentsOf: arrCom)
        return newComponentGroup
    }
    private func addComponents(components: NSArray){
        componentsMutableArray?.addObjects(from: components as! [FGComponent])
    }
    
    private func getComponents()->[FGComponent]{
        return NSArray(array: componentsMutableArray!) as! [FGComponent]
    }

}

class FGControllableGroups: NSObject {
    
    
}
