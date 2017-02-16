//
//  FGEntity.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class FGEntity : NSObject{
    
    /** Entity name and id **/
    var identifier : NSString = ""
    
    var name : NSString = ""
    
    /** Entity auth. **/
    var auth : FGAuth? = nil
    
    /** Entity room. **/
    var room : FGRoom? = nil
    
    /** Entity property. **/
    var property: FGProperty? = nil
    
    /** Entity brand. **/
    var brand: FGBrand? = nil
    
    /** Entity company. **/
    var company: FGCompany? = nil
    
    /** Room login/connect credentials. **/
    var connect : FGConnect? = nil
    
    
    convenience required init(dictionary: Dictionary<String, AnyObject>){
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as! NSString
    }
    
    convenience required init(identifier: NSString){
        self.init()
        self.identifier = identifier
    }
    
    
    public func connectWithObject(connect: FGConnect) {
        
    }
    
    /*
    //REALM DATABASE
    public func saveToRealm(){
        // Insert from NSData containing JSON
        var realm = try! Realm()
        try! realm.write {
            var check = realm.objects(FGEntity.self).count
            if check > 0{
                
            }else{
                realm.add(self, update: true)
            }
        }
        print("*** Saved Entity to Database ***")
    }
    
    public func loadFromRealm() -> FGEntity{
        var realm = try! Realm()
        var entity = realm.object(ofType: FGEntity.self, forPrimaryKey: 0)!
        return entity
    }
    
    public func clearFromRealm(){
        var realm = try! Realm()
        try! realm.write {
            let deletedObject = realm.objects(FGEntity.self).first
            realm.delete(deletedObject!)
        }
        print("*** Clear Entity from Database ***")
    }*/
    
    /*convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init(dictionary)
    }*/
    
    
    /*convenience required init(_ identifier: NSInteger, way: NSString) {
        self.init()
        self.identifier = identifier
    }*/
    
    /*func room() -> FGRoom {
        if self is FGRoom {
            return self as! FGRoom
        }else if self is FGProperty{
            return self.room()
        }else{
            return self as! FGRoom
        }
    }
    
    func property() -> FGProperty {
        
    }
    
    func brand() -> FGProperty {
        
    }
    
    func company() -> FGCompany {
        
    }
     
    dynamic var property: FGProperty? {
         get{
            if self is FGProperty {
                return self as! FGProperty
            }else if self is FGRoom{
                return (self as! FGRoom).parent as! FGProperty
            }else{
                return nil
            }
         }
         set{
            _property = newValue
         }
    }
 
     
     */
    
    
}
