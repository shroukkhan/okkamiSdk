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
        self.name = groupName 
        self.deviceMutableArray = []
    }
    
    convenience required init (deviceGroupWithName name: NSString, devices: NSArray?){
        self.init()
        //let newDeviceGroup = FGDeviceGroup(groupName: name)
        //newDeviceGroup.addDevices(devices: devices)
        self.name = name
        self.addDevices(devices: devices)
        let arrDev = getDevices() as [FGDevice]
        self.devices?.append(contentsOf: arrDev)
        let arrNonGuestDev = getNonGuestDevices() as [FGDevice]
        self.nonGuestDevices?.append(contentsOf: arrNonGuestDev)
    }
    
    func addDevices(devices: NSArray?){
        deviceMutableArray?.addObjects(from: devices as! [FGDevice])
    }
    
    func addDevice(devices: FGDevice){
        self.devices?.append(devices)
        deviceMutableArray?.add(devices)
    }
    
    func getDevices()->[FGDevice]{
        return NSArray(array: deviceMutableArray!) as! [FGDevice]
    }
    
    func getNonGuestDevices()->[FGDevice]{
        let resultPredicate = NSPredicate(format: "type != %@", FGDeviceGuest().type!)
        let arr = deviceMutableArray?.filtered(using: resultPredicate)
        return arr as! [FGDevice]
    }
    
    func devices(with aClass: AnyClass) -> [Any]? {
        return self.devicesCust(with: aClass, identifiers: nil)
    }
    
    func devicesCust(with aClass: AnyClass, identifiers ids: [Any]?) -> [Any]? {
        var devices = [Any]()
        for d: FGDevice in self.devices! {
            if (d.isKind(of: aClass)) {
                if (ids?.count == 0) {
                    devices.append(d)
                }
                else {
                    if self.stringArray(ids!, hasString: d.uid as! String) {
                        devices.append(d)
                    }
                    else {
                        print("device group has no device id: %@", d.uid!)
                    }
                }
            }
        }
        return (devices.count > 0) ? devices : nil
    }
    
    func components(with aClass: AnyClass) -> [Any]? {
        return self.components(with: aClass, identifiers: nil)
    }
    
    func components(with aClass: AnyClass, identifiers ids: [Any]?) -> [Any]? {
        var components = [Any]()
        for d: FGDevice in self.devices! {
            for c: FGComponent in d.components! {
                if (c.isKind(of: aClass)) {
                    if ids == nil {
                        components.append(c)
                    }
                    else {
                        if self.stringArray(ids!, hasString: c.uid as! String) {
                            components.append(c)
                        }
                        else {
                            //FGLogWarnWithClsAndFuncName("device group has no component id: %@", c.uid)
                        }
                    }
                }
            }
        }
        return (components.count > 0) ? components : nil
    }
    func stringArray(_ array: [Any], hasString string: String) -> Bool {
        if array.count == 0 {
            return false
        }
        
        for s in array {
            if (s is String) && (s as! String).lowercased().isEqual(string.lowercased()) {
                return true
            }
        }
        return false
    }
    
    override var description : String {
        return "[<\(NSStringFromClass(self.self as! AnyClass))> \(self.name) (\(self.devices))]"
    }
    
    // compare name and all non phone devices uid
    func isNonGuestDevicesEqual(_ group: FGDeviceGroup) -> Bool {
        if group == nil {
            return false
        }
        if !(self.name == group.name) {
            return false
        }
        
        if self.nonGuestDevices!.count != group.nonGuestDevices!.count {
            return false
        }
        for i in 0..<self.nonGuestDevices!.count {
            let d: FGDevice! = self.nonGuestDevices![i]
            let ad: FGDevice! = group.nonGuestDevices![i]
            if !d!.isEqual(ad) {
                return false
            }
        }
        return true
    }
    // MARK: - internal
    
    func device(fromUID uid: String) -> FGDevice? {
        for d: FGDevice in self.devices! {
            if (d.uid as! String == uid) {
                return d
            }
        }
        return nil
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
        self.name = groupName
        self.componentsMutableArray = []
    }
    
    convenience required init(componentGroupWithName name: NSString, devices: NSArray?){
        self.init()
        //let newComponentGroup = FGComponentGroup(groupName: name)
        //newComponentGroup.addComponents(components: devices)
        self.name = name
        self.componentsMutableArray = []
        let arrCom = getComponents() as [FGComponent]
        self.components?.append(contentsOf: arrCom)
    }
    
    func addComponents(components: NSArray){
        componentsMutableArray?.addObjects(from: components as! [FGComponent])
    }
    
    func getComponents()->[FGComponent]{
        return NSArray(array: componentsMutableArray!) as! [FGComponent]
    }
    
    override var description : String {
        return "[<\(String(describing : self))> \(self.name) (\(self.components))]"
    }
}

class FGControllableGroups: NSObject {
    
    
}
