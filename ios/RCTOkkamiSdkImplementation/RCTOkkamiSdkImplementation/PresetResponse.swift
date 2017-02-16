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
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(dict : Dictionary<String, Any>){
        self.init()
    }
    
    public func saveToRealm(){
        var newData : PresetResponse = PresetResponse()
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        
        try! realm.write {
            var checkPres = realm.objects(PresetResponse).count
            if checkPres > 0{
                
            }else{
                print("*** Saved Preset Response to Database ***")
                realm.add(newData, update: true)
            }
        }
    }
    
    public func loadFromRealm() -> PresetResponse{
        var realm = try! Realm()
        let disc = realm.object(ofType: PresetResponse.self, forPrimaryKey: 0)
        print("*** Load Preset Response From Database ***")
        return disc!
    }
    
    public func clearFromRealm(){
        
    }
}
