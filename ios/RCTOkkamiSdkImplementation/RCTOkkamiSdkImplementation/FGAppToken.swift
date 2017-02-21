//
//  FGAppToken.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/7/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class FGAppToken: Object {
    
    dynamic var id = 0
    dynamic var access_token : NSString = ""
    dynamic var created_at : NSNumber = 0.0
    dynamic var expires_in : NSNumber = 0.0
    dynamic var token_type : NSString = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(_ dictionary: Dictionary<String, AnyObject>) {
        self.init()
        access_token = dictionary["access_token"] as! NSString
        created_at = dictionary["created_at"] as! NSNumber
        expires_in = dictionary["expires_in"] as! NSNumber
        token_type = dictionary["token_type"] as! NSString
    }
    
    public func saveToRealm(){
        let realm = try! Realm()
        let newData : FGAppToken = FGAppToken()
        newData.access_token = access_token
        newData.created_at = created_at
        newData.expires_in = expires_in
        newData.token_type = token_type
        newData.id = 0
        
        // Insert from NSData containing JSON
        try! realm.write {
            realm.add(newData, update: true)
        }
    }
    
    public func loadFromRealm() -> FGAppToken{
        let realm = try! Realm()
        let fgapptoken = realm.object(ofType: FGAppToken.self, forPrimaryKey: 0)
        return fgapptoken!
    }
    
    public func clearFromRealm(){
        
    }
    
}
