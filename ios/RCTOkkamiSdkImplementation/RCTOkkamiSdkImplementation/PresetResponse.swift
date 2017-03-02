//
//  PresetResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/15/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class PresetResponse: Object {
    
    dynamic var id = 0
    dynamic var preset : NSString = ""
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dict : Dictionary<String, Any>){
        self.init()
        let jsonData: Data = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        self.preset = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
    }
    
    public func saveToRealm(){
        let newData : PresetResponse = PresetResponse()
        newData.preset = preset
        
        // Insert from NSData containing JSON
        let realm = try! Realm()
        
        try! realm.write {
            /*var checkPres = realm.objects(PresetResponse).count
            if checkPres > 0{
                
            }else{
                print("*** Saved Preset Response to Database ***")
                realm.add(newData, update: true)
            }*/
            print("*** Saved Preset Response to Database ***")
            realm.add(newData, update: true)
        }
    }
    
    public func loadFromRealm() -> PresetResponse{
        let realm = try! Realm()
        let pres = realm.object(ofType: PresetResponse.self, forPrimaryKey: 0)
        print("*** Load Preset Response From Database ***")
        return pres!
    }
    
    public func clearFromRealm(){
        
    }
}
