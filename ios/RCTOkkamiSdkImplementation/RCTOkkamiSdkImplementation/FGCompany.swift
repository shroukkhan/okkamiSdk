//
//  FGCompany.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class FGCompany: FGEntity {
 
    convenience required init(identifier: NSNumber) {
        self.init()
        self.identifier = identifier
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as! NSNumber
    }
    
    /*public override func loadFromRealm() -> FGCompany{
        var realm = try! Realm()
        var company = realm.object(ofType: FGCompany.self, forPrimaryKey: 0)!
        return company
    }
    
    public override func saveToRealm(){
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        try! realm.write {
            var check = realm.objects(FGCompany.self).count
            if check > 0{
                
            }else{
                realm.add(self, update: true)
            }
        }
        print("*** Saved Company to Database ***")
    }
    
    public override func clearFromRealm(){
        var realm = try! Realm()
        try! realm.write {
            let deletedObject = realm.objects(FGCompany.self).first
            realm.delete(deletedObject!)
        }
        print("*** Clear Company from Database ***")
    }*/
    
}
