//
//  FGConnect.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/4/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Realm

class FGConnect: NSObject, NSCoding {
    var name : NSString = ""
    var tokenRoom : NSString = ""
    var room_id : NSString = ""
    
    convenience required init(nameRoom: NSString, roomToken : NSString, rooms_id : NSString) {
        self.init()
        name = nameRoom
        tokenRoom = roomToken
        room_id = rooms_id
    }
    
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        /*identifier = aDecoder.decodeObject(forKey: "identifier") as! NSNumber
        guest_id = aDecoder.decodeObject(forKey: "guest_id") as! NSString
        uid = aDecoder.decodeObject(forKey: "uid") as! NSString
        var data : NSData = aDecoder.decodeObject(forKey: "auth") as! NSData
 
        do {
            try auth = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! FGAuth
        } catch (exception() as! NSException) as! Realm.Error {
            auth = FGAuth()
        } */
    }
    
    public func encode(with aCoder: NSCoder) {
        /*
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(guest_id, forKey: "guest_id")
        aCoder.encode(uid, forKey: "uid")
        var data : NSData = NSKeyedArchiver.archivedData(withRootObject: auth) as NSData
        aCoder.encode(data, forKey: "auth")*/
    }
    
    /*public func saveToRealm(){
        var realm = try! Realm()
        var newData : FGConnect = FGConnect()
        newData.name = name
        newData.tokenRoom = tokenRoom

        // Insert from NSData containing JSON
        try! realm.write {
            realm.add(newData, update: true)
        }
    }*/
    
    /*public func loadFromRealm(room_id : NSNumber) -> FGConnect{
        var realm = try! Realm()
        let connect = realm.objects(FGConnect.self).filter("room_id == %@", room_id).first
        return connect!
    }
    
    public func clearFromRealm(){
        
    }*/
}
