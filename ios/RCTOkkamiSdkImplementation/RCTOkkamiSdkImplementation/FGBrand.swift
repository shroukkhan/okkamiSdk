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
    
    
    /** parent entity. */
    var parent : FGEntity?{
        get{
            return self.company
        }
    }
    
    public func getParent() -> FGEntity?{
        return self.company
    }
    
    
    convenience required init(identifier: NSNumber) {
        self.init()
        self.identifier = identifier
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as! NSNumber
    }
    
    /*public override func saveToRealm(){
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        try! realm.write {
            var check = realm.objects(FGBrand.self).count
            if check > 0{
                
            }else{
                realm.add(self, update: true)
            }
        }
        print("*** Saved Brand to Database ***")
    }
    
    public override func loadFromRealm() -> FGBrand{
        var realm = try! Realm()
        var brand = realm.object(ofType: FGBrand.self, forPrimaryKey: 0)!
        print("*** Clear Brand from Database ***")
        return brand
    }
    public override func clearFromRealm(){
        var realm = try! Realm()
        try! realm.write {
            //let deletedObject = realm.objects(FGBrand.self).filter("company == \(self.company)")
            let deletedObject = realm.objects(FGBrand.self).first
            realm.delete(deletedObject!)
        }
        print("*** Clear Brand from Database ***")
    }*/
}
