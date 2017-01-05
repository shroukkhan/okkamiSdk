//
//  RCTOkkamiMain.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 12/29/16.
//  Copyright © 2016 michaelabadi.com. All rights reserved.
//
import UIKit

@objc public class RCTOkkamiMain: NSObject {
    
    //var bridge: RCTBridge!
    //var bridge: RCTBridge!
    
    public class func newInstance() -> RCTOkkamiMain {
        return RCTOkkamiMain()
    }
    
    public func hello() {
        print("hello world")
    }
    
    /*public func testEvent( eventName: String ) {
        self.bridge.eventDispatcher.sendAppEventWithName( eventName, body: "Woot!" )
    }*/

}
