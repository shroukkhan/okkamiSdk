//
//  FGLink.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation
/** Defines states that links should be displayed */
enum FGLinkState : Int {
    /** Link should always appear */
    case all = 0
    /** Link should appear only when connected */
    case connected = 1
    /** Link should appear only when disconnected */
    case disconnected = 2
}

/** Represents a link title and URL */
class FGLink: NSObject {
    var title: String = ""
    var url: URL!
    var state = FGLinkState(rawValue: 0)
    /** Create objects from array of array of 2 strings.
     @[@[@"title1",@"www.web1.com",All],@[@"title2",@"www.web2.com"]] */
    
    class func links(withArray array: [FGLink]) -> [FGLink]? {
        if array.count < 1 {
            return nil
        }
        var m = [FGLink]()
        for dict in array {
            let l: FGLink? = dict
            if l != nil {
                m.append(l!)
            }
        }
        
        return m
    }
    
    class func state(from string: String) -> FGLinkState {
        var _string = string
        _string = _string.lowercased()
        if (_string == "connected") {
            return .connected
        }
        else if (string == "disconnected") {
            return .disconnected
        }
        else {
            return .all
        }
        
    }
    
    init(dictionary dict: [AnyHashable: Any]) {
        super.init()
        self.title = dict["title"] as! String
        self.url = URL(string: dict["url"] as! String)
        self.state = FGLink.state(from: dict["state"] as! String)
    }
    
    func state(from string: String) -> FGLinkState {
        var _string = string
        _string = _string.lowercased()
        if (_string == "connected") {
            return .connected
        }
        else if (string == "disconnected") {
            return .disconnected
        }
        else {
            return .all
        }
        
    }
}
