//
//  FGObject.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGObject: NSObject {
    
    convenience init(dictionary dict: [AnyHashable: Any]) {
        //    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
        //    FGObject *obj = [[FGObject alloc] init];
        //    if (obj) {
        //        // set obj properties from dictionary
        //        obj.title    = [dict[@"title"] toNSString];
        //    }
        //    return obj;
        self.init()
    }
    
    func objects(withArray array: [Any]) -> [Any] {
        var m = [Any]()
        for d in array {
            let obj: Any? = FGObject(dictionary: d as! [AnyHashable : Any])
            if obj != nil {
                m.append(obj!)
            }
        }
        return [Any](arrayLiteral: m)
    }}
