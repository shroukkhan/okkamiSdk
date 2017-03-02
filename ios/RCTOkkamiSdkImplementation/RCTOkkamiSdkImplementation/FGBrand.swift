//
//  FGBrand.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class FGBrand: FGEntity {
    
    /** Children */
    var properties = [FGProperty]()
    /** Adds brand and sets its brand property. */
    
    var connReloadRoomInfo: NSURLConnection!
    var connConnect: NSURLConnection!
    var connDisconnect: NSURLConnection!

    
    /** parent entity. */
    override var parent : FGEntity?{
        get{
            return self.company
        }set{
            self.parent = newValue
        }
    }
    
    public func getParent() -> FGEntity?{
        return self.company
    }
    
    
    convenience required init(identifier: NSString) {
        self.init()
        self.identifier = identifier
        self.properties = [FGProperty]()
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as? NSString
    }
    
    override var description: String {
        var desc: String = super.description
        for p: FGProperty in self.properties {
            desc = desc.appendingFormat("\n    ╚═%@", p.description)
        }
        return desc
    }
    
    func property(withIdentifier identifier: Int) -> FGProperty? {
        for b: FGProperty in self.properties {
            if (b.identifier as! String) == identifier.description {
                return b
            }
        }
        return nil
    }
    // MARK: - parent and children
    
    func add(_ property: FGProperty) {
        property.brand = self
        self.properties.append(property)
    }
    
    override var children: [Any]?{
        get{
            return self.properties
        }set{
            self.children = newValue
        }
    }
    // MARK: - connect
    
    /*public override func connectWithObject(connect: FGConnect, completionBlock: @escaping (_: FGProperty) -> Void) {
        weak var weakSelf = self
        // verify
        if !(connect is FGConnect) {
            return
        }
        var reachable: Bool? = FGReachability.isReachableAndShowAlertIfNo(withRetryHandler: {() -> Void in
            weakSelf?.connect(withObject: connect, completionBlock: completionBlock)
            // retry
        })
        if reachable == nil {
            return
        }
        // keep track of connect, and add entity line to it
        connect.line = try! FGEntityLine.fromCompanyId(self.company.identifier, brandId: self.identifier, propertyId: 0)
        self.connect = connect
        self.connConnect.cancel()
        
        // cancel any connection that may exist
        self.connConnect = FGHTTP.sharedInstance.postConnectToRoom(withEntity: self, with: connect.name, code: connect.code, callback: {(_ property: FGProperty) -> Void in
            completionBlock(property)
        })
    }*/
}
