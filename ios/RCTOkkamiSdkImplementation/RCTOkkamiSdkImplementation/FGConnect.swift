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
    var line : FGEntityLine?
    
    convenience required init(nameRoom: NSString, roomToken : NSString, rooms_id : NSString) {
        self.init()
        name = nameRoom
        tokenRoom = roomToken
        room_id = rooms_id
    }
    
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        name = aDecoder.decodeObject(forKey: "name") as! NSString
        tokenRoom = aDecoder.decodeObject(forKey: "tokenRoom") as! NSString
        room_id = aDecoder.decodeObject(forKey: "room_id") as! NSString
        let data : NSData = aDecoder.decodeObject(forKey: "line") as! NSData
 
        do {
            try line = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? FGEntityLine
        } catch {
            print("error")
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(name, forKey: "name")
        aCoder.encode(tokenRoom, forKey: "tokenRoom")
        aCoder.encode(room_id, forKey: "room_id")
        let data : NSData = NSKeyedArchiver.archivedData(withRootObject: line!) as NSData
        aCoder.encode(data, forKey: "line")
    }
    
}
