//
//  FGDevice.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class FGDevice: FGControllableBase {
    
    /** The device group that this device is in. */
    var group : FGDeviceGroup? = nil
    
    /** FGComponentBase objects that this device contains, sorted by uid in ascending order. */
    var components : [FGComponent]? = nil
    
    override var type: NSString?{
        get{
            return self.type
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
    
    
    /** Creates a FGDevice object.
     
     @param dict NSDictionary object containing device information. `devices` key in room data.
     @returns FGDeviceGroup object. Nil if unknown device type;
     */
    public func deviceWithDictionary(dictionary: Dictionary<String, Any>)->FGDevice?{
        
        /*if !dict.toNSDictionary() {
         return nil
         }*/
        
        // choose a subclass to init based on device type
        let type = dictionary["device_type"] as! NSString
        let k = classForType(type: type)
        if k == nil || !k!.isSubclass(of: FGDevice.self) {
            print("no class for type: %@ \tuid: %@", type, dictionary["component_uid"]!)
            return nil
        }
        
        print("assigned class: %@ \tfor type: %@ \tuid: %@", k, type, dictionary["component_uid"]!)
        return k as? FGDevice
        
    }
    
    override init() {
        
    }
    
    init(dictionary : Dictionary<String, Any>){
        super.init()
        self.uid = dictionary["device_uid"] as? NSString
        self.name = dictionary["name"] as? NSString
        self.type = dictionary["device_type"] as? NSString
        var mComps : [Any] = []
        let compArray : [Any] = dictionary["components"] as! Array

        if compArray.count > 0 {
            for compDict in compArray {
                let comp = FGComponent(dictionary: compDict as! Dictionary<String, Any>)
                if (comp != nil){
                    mComps.append(comp as FGComponent)
                }
            }
        }
    }
    
    public func classForType(type : NSString)->AnyClass?{
        if type is NSString {
            for k: AnyClass in FGDevice.allSubclasses() {
                let compare = (k as! FGDevice).type as! String
                if type.caseInsensitiveCompare(compare) == ComparisonResult.orderedSame {
                    return k
                }
            }
        }
        return nil
    }
    
    override func isEqual(_ device: Any?) -> Bool {
        if super.isEqual(device) {
            if self.components?.count != (device as! FGDevice).components?.count {
                return false
            }
            for i in 0..<self.components!.count {
                let c: FGComponent = self.components![i]
                let ac: FGComponent = (device as! FGDevice).components![i]
                if !c.isEqual(ac) {
                    return false
                }
            }
            return true
        }
        else {
            return false
        }
    }
    
    func component(withID uid: String) -> FGComponent? {
        for c: FGComponent in self.components! {
            if c.uid!.isEqual(to: uid) {
                return c
            }
        }
        return nil
    }
    
    /** Adds necessary FGSocket message observers to the receiver.
     Subclass should call super implementation which handles logging. */
    func addMessageObservers() {
        print("name:%@ (uid:%@)", self.name!, self.uid!)
    }
    
    /** Removes all FGSocket message observers from the receiver. */
    func removeMessageObservers(){
        
    }
    
}
