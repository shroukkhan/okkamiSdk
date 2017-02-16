//
//  PreconnectResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class Authentication : Object{
    
    dynamic var token : NSString = ""
    dynamic var secret : NSString = ""
    
    convenience init(node : Dictionary<String, Any>) {
        self.init()
        self.token = node["auth_token"] as! NSString
        self.secret = node["auth_secret"] as! NSString
    }
}

class PreconnectResponse: Object {
    dynamic var id = 0
    dynamic var identifier : NSString = ""
    dynamic var guest_id : NSString = ""
    dynamic var uid : NSString = ""
    dynamic var auth : Authentication? = nil
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        var guestDeviceDict : NSDictionary = dictionary["guest_device"] as! NSDictionary
        self.identifier = (guestDeviceDict["id"] as! NSNumber).stringValue as NSString
        if ((guestDeviceDict["guest_id"] as? NSString) != nil) {
            self.guest_id = guestDeviceDict["guest_id"] as! NSString
        }else{
            self.guest_id = ""
        }
        self.uid = guestDeviceDict["uid"] as! NSString
        var auth : Authentication = Authentication(node: guestDeviceDict["authentication"] as! Dictionary<String, Any>)
        self.auth = auth
    }
    
    public func saveToRealm(){
        var newData : PreconnectResponse = PreconnectResponse()
        newData.identifier = identifier
        newData.guest_id = guest_id
        newData.uid = uid
        newData.auth = auth
        newData.id = 0
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        
        try! realm.write {
            var checkPrec = realm.objects(PreconnectResponse).count
            if checkPrec > 0{
            
            }else{
                print("*** Saved Preconnect to Database ***")
                realm.add(newData, update: true)
            }
        }
    }
    
    public func loadFromRealm() -> PreconnectResponse{
        var realm = try! Realm()
        let preconnect = realm.object(ofType: PreconnectResponse.self, forPrimaryKey: 0)
        print("*** Load Preconnect From Database ***")
        return preconnect!
    }
    
    public func clearFromRealm(){
        
    }

}
