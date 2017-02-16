//
//  DisconnectRoomResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/15/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class DisconnectRoomResponse: Object {
    
    dynamic var id = 0
    dynamic var success : Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dict : Dictionary<String, Any>){
        self.init()
        self.success = dict["success"] as! Bool
    }
    
    public func saveToRealm(){
        var newData : DisconnectRoomResponse = DisconnectRoomResponse()
        newData.success = success
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        
        try! realm.write {
            var checkPrec = realm.objects(DisconnectRoomResponse).count
            if checkPrec > 0{
                
            }else{
                print("*** Saved Disconnect Response to Database ***")
                realm.add(newData, update: true)
            }
        }
    }
    
    public func loadFromRealm() -> DisconnectRoomResponse{
        var realm = try! Realm()
        let disc = realm.object(ofType: DisconnectRoomResponse.self, forPrimaryKey: 0)
        print("*** Load Disconnect Response From Database ***")
        return disc!
    }
    
    public func clearFromRealm(){
        
    }
}
