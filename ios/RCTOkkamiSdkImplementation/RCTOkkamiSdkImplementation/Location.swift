//
//  Location.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/19/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object {
    
    dynamic var id = 0
    dynamic var latitude : NSString = ""
    dynamic var longitude : NSString = ""
    dynamic var countryName : NSString = ""
    dynamic var cityName : NSString = ""
    dynamic var stateName : NSString = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dict : Dictionary<String, Any>){
        self.init()
        self.latitude = dict["latitude"] as! NSString
        self.longitude = dict["longitude"] as! NSString
        self.countryName = dict["country_name"] as! NSString
        self.cityName = dict["city_name"] as! NSString
        self.stateName = dict["state_name"] as! NSString
    }
    
    public func saveToRealm(){
        let newData : Location = Location()
        newData.latitude = latitude
        newData.longitude = longitude
        newData.countryName = countryName
        newData.cityName = cityName
        newData.stateName = stateName
        
        // Insert from NSData containing JSON
        let realm = try! Realm()
        
        try! realm.write {
            print("*** Saved Location to Database ***")
            realm.add(newData, update: true)
        }
    }
    
    public func loadFromRealm() -> Location{
        let realm = try! Realm()
        let pres = realm.object(ofType: Location.self, forPrimaryKey: 0)
        print("*** Load Location From Database ***")
        return pres!
    }
    
    public func clearFromRealm(){
        
    }
}
