//
//  APIResponseCall.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/21/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class APIResponseCall: Object {
    

    dynamic var id = 0
    dynamic var response : String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(response : String){
        self.init()
        self.response = response
    }
    
    public func saveToRealm(){
        let newData : APIResponseCall = APIResponseCall()
        newData.response = response
        // Insert from NSData containing JSON
        let realm = try! Realm()
        
        try! realm.write {
            print("*** Saved API Response Call to Database ***")
            realm.add(newData, update: true)
        }
    }
    
    public func loadFromRealm() -> APIResponseCall{
        let realm = try! Realm()
        let apicall = realm.object(ofType: APIResponseCall.self, forPrimaryKey: 0)
        print("*** Load API Response Call From Database ***")
        return apicall!
    }
    
    public func clearFromRealm(){
        
    }
}
