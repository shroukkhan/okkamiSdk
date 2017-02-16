//
//  FGComponent.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class FGComponent: FGControllableBase {
    
    var device : FGDevice?
    var config : Dictionary<String,Any>?
    
    
    /** Creates a FGDevice object.
     
     @param dict NSDictionary object containing device information. `components` key in room data.
     @returns FGDeviceGroup object.
     */
    
    public func componentWithDictionary(dictionary : Dictionary<String, Any>)->FGComponent?{
        
        // choose a subclass to init based on device type
        var type = dictionary["component_type"] as! NSString
        var k = classForType(type: type)
        if k == nil {
            print("no class for type : %@ \tuid: %@",type,dictionary["component_uid"])
            return nil
        }
        
        print("assigned class: %@ \tfor type: %@ \tuid: %@",k,type,dictionary["component_uid"])
        return k!
    }
    
    override init() {
        
    }
    
    init(dictionary : Dictionary<String, Any>){
        super.init()
        self.uid = dictionary["component_uid"] as! NSString
        self.name = dictionary["name"] as! NSString
        self.type = dictionary["component_type"] as! NSString
        self.config = dictionary["config"] as! Dictionary<String, Any>?
        
    }
    
    public func classForType(type : NSString)->FGComponent?{
        if type is NSString {
            for k in FGComponent().allSubclasses() {
                var compare = (k as! FGComponent).getType() as String
                if type.caseInsensitiveCompare(compare) == ComparisonResult.orderedSame {
                    return k as! FGComponent
                }
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
}
