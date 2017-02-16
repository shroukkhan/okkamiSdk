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
    private var group : FGDeviceGroup? = nil
    
    /** FGComponentBase objects that this device contains, sorted by uid in ascending order. */
    private var components : Array<FGComponent>? = nil
    
    
    /** Creates a FGDevice object.
     
     @param dict NSDictionary object containing device information. `devices` key in room data.
     @returns FGDeviceGroup object. Nil if unknown device type;
     */
    public func deviceWithDictionary(dictionary: Dictionary<String, Any>)->FGDevice?{
        
        // choose a subclass to init based on device type
        var type = dictionary["device_type"] as! NSString
        var k = classForType(type: type)
        if k == nil {
            print("no class for type : %@ \tuid: %@",type,dictionary["component_uid"]!)
            return nil
        }
        
        print("assigned class: %@ \tfor type: %@ \tuid: %@",k,type,dictionary["component_uid"]!)
        return k!
    }
    
    override init() {
        
    }
    
    init(dictionary : Dictionary<String, Any>){
        super.init()
        self.uid = dictionary["device_uid"] as! NSString
        self.name = dictionary["name"] as! NSString
        self.type = dictionary["device_type"] as! NSString
        var mComps : [Any] = []
        var compArray : [Any] = dictionary["components"] as! Array
        
        if compArray.count > 0 {
            for compDict in compArray {
                var comp = FGComponent().componentWithDictionary(dictionary: compDict as! Dictionary<String, Any>)
                if (comp != nil){
                    mComps.append(comp! as FGComponent)
                }
            }
        }
    }
    
    public func classForType(type : NSString)->FGDevice?{
        if type is NSString {
            for k in FGDevice().allSubclasses() {
                var compare = (k as! FGDevice).getType() as String
                if type.caseInsensitiveCompare(compare) == ComparisonResult.orderedSame {
                    return k as! FGDevice
                }
            }
        }
        return nil
    }
    private func componentWithID(uid : NSString)->FGComponent?{
        for c in self.components! {
            if c.uid.isEqual(to: uid as String) {
                return c
            }
        }
        return nil
    }
    override func getType() -> NSString {
        return self.getType()
    }
    
    public func allSubclasses()->NSArray{
        var result : NSArray? = nil
        result = [FGLight.self, FGRadio.self, FGCurtain.self]
        //need FGAirCon and FGTV too
        return result!
    }
    
    
    /** Removes all FGSocket message observers from the receiver. */
    public func removeMessageObserver(){
        
    }
    
    //isEqual Method not yet implemented
    
    /** Queries a component with the given `uid`.
     @param uid FGComponentBase uid.
     @returns FGComponentBase object.
     */
    
    /*public func componentWithID(uid: NSString)->FGComponent?{
        for (FGComponent *c in self.components) {
            if ([c.uid isEqualToString:uid]) {
                return c;
            }
        }
        return nil;
    }*/
    
    /** Adds necessary FGSocket message observers to the receiver.
     Subclass should call super implementation which handles logging. */
    public func addMessageObservers(){

    }
    
    /** Specifies type that will be matched with `device_type` key in
     room data to determine the correct class.
     */
    
}
