//
//  ConnectRoomResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class ConnectRoomResponse: Object {
    
    dynamic var id = 0
    dynamic private var auth : Authentication? = nil
    dynamic private var room : Room? = nil

    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        var auth : Authentication = Authentication(node: dictionary)
        var room : Room = Room(node: dictionary)
        self.auth = auth
        self.room = room
    }
    
    public func saveToRealm(){
        var newData : ConnectRoomResponse = ConnectRoomResponse()
        newData.id = 0
        newData.auth = auth
        newData.room = room

        // Insert from NSData containing JSON
        var realm = try! Realm()
        
        try! realm.write {
            var checkConn = realm.objects(ConnectRoomResponse).count
            if checkConn > 0{
                
            }else{
                print("*** Saved Room Response to Database ***")
                realm.add(newData, update: true)
            }
        }
    }
    
    public func loadFromRealm() -> ConnectRoomResponse{
        var realm = try! Realm()
        let preconnect = realm.object(ofType: ConnectRoomResponse.self, forPrimaryKey: 0)
        print("*** Load Room Response From Database ***")
        return preconnect!
    }
    
    public func clearFromRealm(){
        
    }
    
    private class Authentication : Object{
        
        dynamic var token : NSString = ""
        dynamic var secret : NSString = ""
        
        convenience init(node : Dictionary<String, Any>) {
            self.init()
            self.token = node["token"] as! NSString
            self.secret = node["secret"] as! NSString
        }
    }
    
    private class Room : Object {
    
        dynamic var company_id : NSString = "-1"
        dynamic var brand_id : NSString = "-1"
        dynamic var property_id : NSString = "-1"
        dynamic var room_id : NSString = "-1"
        dynamic var number : NSString = "-1"
        dynamic var presetsAsJson : NSString = ""
        dynamic var groupsAsJson : NSString = ""
        dynamic var checked_inAsJson : NSString = ""
        dynamic var devicesAsJson : NSString = ""
        dynamic var frcdsAsJson : NSString = ""
        
        convenience required init (node : Dictionary<String, Any>) {
            self.init()
            self.company_id = node["company_id"] as! NSString
            self.brand_id = node["brand_id"] as! NSString
            self.property_id = node["property_id"] as! NSString
            self.room_id = node["room_id"] as! NSString
            self.number = node["number"] as! NSString
            self.presetsAsJson = node["presets"] as! NSString
            self.groupsAsJson = node["groups"] as! NSString
            self.checked_inAsJson = node["checked_in"] as! NSString
            self.devicesAsJson = node["devices"] as! NSString
            self.frcdsAsJson = node["frcds"] as! NSString
        }
    }
    

}
