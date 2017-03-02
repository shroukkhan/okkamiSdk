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
    
    func removeMessageObservers() {
        //self.bk_removeAllBlockObservers()
    }
 
    
    func isConfigEmpty() -> Bool {
        return self.config == nil || self.config?.values.count == 0
    }
    
    public func componentWithDictionary(dict : Dictionary<String, Any>)->FGComponent?{
        /*if !dict.toNSDictionary() {
         return nil
         }*/
        
        // choose a subclass to init based on device type
        let type: String = dict["component_type"] as! String
        let k = classForType(type: type as NSString)
        if k == nil || !k!.isKind(of: FGComponent.self) {
            print("no class for type: %@ \tuid: %@", type, dict["component_uid"]!)
            return nil
        }
        print("assigned class: %@ \tfor type: %@ \tuid: %@", k!, type, dict["component_uid"]!)
        
        return k as? FGComponent
    }
    
    
    init(dictionary : Dictionary<String, Any>){
        /*if !dict.toNSDictionary() {
            return nil
        }*/
        
        super.init()
        self.uid = dictionary["component_uid"] as? NSString
        self.name = dictionary["name"] as? NSString
        self.type = dictionary["component_type"] as? NSString
        self.config = dictionary["config"] as! Dictionary<String, Any>?
        self.setupComponent(withConfig: self.config!)
        
    }
    
    public func classForType(type : NSString)->AnyObject? {
        for k in FGComponent.allSubclasses() {
            let compare = String(describing: k)
            if type.caseInsensitiveCompare(compare) == ComparisonResult.orderedSame {
                return k
            }
        }
        return nil
    }
    
    override var type: NSString?{
        get{
            return self.type
        }
        set{
            self.type = newValue
        }
    }
    
    /*override func getType() -> String {
        return self.self.getType()
    }*/
    
    func addMessageObservers() {
        print("name:%@ (uid:%@)", self.name!, self.uid!)
    }
    
    func setupComponent(withConfig config: [AnyHashable: Any]) {
        
    }
    
    /*public func allSubclasses()->NSArray{
        var result : NSArray? = nil
        result = [FGLight.self, FGRadio.self, FGCurtain.self]
        //need FGAirCon and FGTV too
        return result!
    }*/
}
