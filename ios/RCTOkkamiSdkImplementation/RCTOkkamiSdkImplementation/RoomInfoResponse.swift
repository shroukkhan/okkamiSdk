//
//  RoomInfoResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/16/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class RoomInfoResponse: Object {
    
    dynamic var id = 0
    dynamic var roominfo : Room? = nil
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dict : Dictionary<String, Any>){
        self.init()
        self.roominfo = Room(node: dict)
    }
    
    public func saveToRealm(){
        var newData : RoomInfoResponse = RoomInfoResponse()
        newData.roominfo = roominfo
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        
        try! realm.write {
            var checkPres = realm.objects(RoomInfoResponse).count
            if checkPres > 0{
                
            }else{
                print("*** Saved Room Info Response to Database ***")
                realm.add(newData, update: true)
            }
        }
    }
    
    public func loadFromRealm() -> RoomInfoResponse{
        var realm = try! Realm()
        let room = realm.object(ofType: RoomInfoResponse.self, forPrimaryKey: 0)
        print("*** Load Room Info Response From Database ***")
        return room!
    }
    
    public func clearFromRealm(){
        
    }
}
