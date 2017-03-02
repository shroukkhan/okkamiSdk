//
//  FGMailbox.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

import Foundation
let FGMailbox_INVALID_ID = NSIntegerMax
enum FGMailboxEntityType : Int {
    case _Company
    case _Brand
    case _Property
    case _Unknown
}

class FGMailbox: NSObject {
    /** True if this mailbox is the default mailbox for the property */
    var isDefault: Bool = true
    /** Email address where the messages sent to this mailbox will be forwarded */
    var email: String = ""
    /** Publicly visible name of the mailbox */
    var name: String = ""
    /** This mailbox's identifying number */
    var identifier: NSNumber!
    /** The object type that owns this particular mailbox; eg Company, Brand, or Property */
    var entityType = FGMailboxEntityType(rawValue: 0)
    /** The identifier for the specific object that owns this particular mailbox; eg Company, Brand, or Property id */
    var entityId: Int = 0
    
    class func mailboxes(fromArrayOfDictionaries array: [Any]) -> [Any] {
        var m: [Any]?
        if (array.count > 0) {
            m = [Any]()
            //array = array.filteredArrayForKind(ofClass: [AnyHashable: Any].self)
            for d in array {
                let mailbox: FGMailbox? = FGMailbox(dictionary: d as! [AnyHashable: Any])
                if mailbox != nil {
                    m?.append(mailbox!)
                }
            }
        }
        return [Any](arrayLiteral: m!)
    }
    
    override init() {
        super.init()
        self.isDefault = false
        self.identifier = (FGMailbox_INVALID_ID as NSNumber!)
        
    }
    
    convenience init(dictionary dict: [AnyHashable: Any]) {
        self.init()
        self.isDefault = (dict["default"] as! NSString).boolValue
        self.name = (dict["name"] as? String)!
        self.email = (dict["email"] as? String)!
        self.identifier = (dict["id"] as? NSString)?.integerValue as NSNumber!
        self.entityType = self.type(from: (dict["postboxable_type"] as? String)!)
        self.entityId = ((dict["postboxable_id"] as? NSString)?.integerValue)!
        
    }
    
    func type(from string: String) -> FGMailboxEntityType {
        let _string = string
        if _string.isEqual(toStringCaseInsensitive: "Company") {
            return ._Company
        }
        else if _string.isEqual(toStringCaseInsensitive: "Brand") {
            return ._Brand
        }
        else if _string.isEqual(toStringCaseInsensitive: "Property") {
            return ._Property
        }
        else {
            return ._Unknown
        }
        
    }
    
    override var description: String {
        return "[<\(NSStringFromClass(FGMailbox.self))> id:\(Int(CInt(self.identifier))) name:\(self.name)]"
    }
}
