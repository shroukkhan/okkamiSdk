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
    dynamic var group : FGDeviceGroup? = nil
    
    /** FGComponentBase objects that this device contains, sorted by uid in ascending order. */
    //var components : Array<FGComponent>? = nil
    
    convenience required init(dictionary: Dictionary<String, Any>){
        self.init()
        
    }
    
    /** Removes all FGSocket message observers from the receiver. */
    public func removeMessageObserver(){
        
    }
    
    /** Queries a component with the given `uid`.
     @param uid FGComponentBase uid.
     @returns FGComponentBase object.
     */
    
    public func componentWithID(uid: NSString)->FGComponent{
        return FGComponent()
    }
    
    /** Adds necessary FGSocket message observers to the receiver.
     Subclass should call super implementation which handles logging. */
    public func addMessageObservers(){

    }
    
    /** Specifies type that will be matched with `device_type` key in
     room data to determine the correct class.
     */
    
}
