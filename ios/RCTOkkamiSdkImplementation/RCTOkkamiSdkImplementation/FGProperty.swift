//
//  FGProperty.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class FGProperty: FGEntity {
    
    /** parent entity. */
    var parent : FGEntity?{
        get{
            return self.brand
        }
    }
    public func getParent() -> FGEntity?{
        return self.brand
    }
    
    convenience required init(identifier: NSString) {
        self.init()
        self.identifier = identifier
        self.room = FGRoom(identifier: "0")
        self.room?.property = self
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as! NSString
    }
    
    /*public override func saveToRealm(){
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        try! realm.write {
            var check = realm.objects(FGProperty.self).count
            if check > 0{
                var checkRoom = realm.objects(FGRoom.self).count
                if checkRoom > 0{
                    
                }else{
                    realm.add(self, update: true)
                }
            }else{
                realm.add(self, update: true)
            }
        }
        print("*** Saved Property to Database ***")
    }
    
    public override func loadFromRealm() -> FGProperty{
        var realm = try! Realm()
        var property = realm.object(ofType: FGProperty.self, forPrimaryKey: 0)!
        print("*** Load Property from Database ***")
        return property
    }
    
    public override func clearFromRealm(){
        var realm = try! Realm()
        try! realm.write {
            //let deletedObject = realm.objects(FGProperty.self).filter("brand == \(self.brand)")
            let deletedObject = realm.objects(FGProperty.self).first
            realm.delete(deletedObject!)
        }
        print("*** Clear Property from Database ***")
    }*/
    
}
