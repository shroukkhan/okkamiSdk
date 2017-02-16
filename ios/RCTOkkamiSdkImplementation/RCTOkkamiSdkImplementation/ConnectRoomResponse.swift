//
//  ConnectRoomResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift


class Room : Object {
    
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
        self.company_id = (node["company_id"] as! NSNumber).stringValue as! NSString
        self.brand_id = (node["brand_id"] as! NSNumber).stringValue as! NSString
        self.property_id = (node["property_id"] as! NSNumber).stringValue as! NSString
        self.room_id = (node["room_id"] as! NSNumber).stringValue as! NSString
        self.number = node["number"] as! NSString
        var jsonPresetData: NSData = try! JSONSerialization.data(withJSONObject: node["presets"], options: .prettyPrinted) as NSData
        self.presetsAsJson = NSString(data: jsonPresetData as Data, encoding: String.Encoding.utf8.rawValue)!
        var groupString = ((node["groups"] as! NSArray).description) as! NSString
        self.groupsAsJson = groupString
        var jsonCheckData: NSData = try! JSONSerialization.data(withJSONObject: node["checked_in"], options: .prettyPrinted) as NSData
        self.checked_inAsJson = NSString(data: jsonCheckData as Data, encoding: String.Encoding.utf8.rawValue)!
        var devicesString = ((node["devices"] as! NSArray).description) as! NSString
        var frcdString = ((node["frcds"] as! NSArray).description) as! NSString
        self.devicesAsJson = devicesString
        self.frcdsAsJson = frcdString
    }
}

class ConnectRoomResponse: Object {
    
    dynamic var id = 0
    dynamic var auth : Authentication? = nil
    dynamic var room : Room? = nil
    dynamic var roomName : NSString = ""
    dynamic var roomToken : NSString = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>, name: NSString, token: NSString ) {
        self.init()
        var auth : Authentication = Authentication(node: dictionary["authentication"] as! Dictionary<String, Any>)
        var room : Room = Room(node: dictionary["room"] as! Dictionary<String, Any>)
        self.auth = auth
        self.room = room
        self.roomName = name
        self.roomToken = token
    }
    
    public func saveToRealm(){
        var newData : ConnectRoomResponse = ConnectRoomResponse()
        newData.id = 0
        newData.auth = auth
        newData.room = room
        newData.roomToken = roomToken
        newData.roomName = roomName
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
    
    public func loadFromRealm() -> ConnectRoomResponse?{
        var realm = try! Realm()
        let preconnect = realm.object(ofType: ConnectRoomResponse.self, forPrimaryKey: 0)
        print("*** Load Room Response From Database ***")
        return preconnect
    }
    
    public func clearFromRealm(){
        
    }
}
