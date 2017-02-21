//
//  GuestServiceResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class GuestObject : Object{
    dynamic var id : String?
    dynamic var title : String?
    dynamic var subtitle : String?
    dynamic var node_type : String?
    dynamic var picture : String?
    dynamic var tag : String?
    dynamic var data : String?
    dynamic var icon : String?
    dynamic var display_on : String?
    dynamic var children : String?
    dynamic var start_time : String?
    dynamic var end_time : String?
    dynamic var weekday_frequency : String?
    dynamic var type : String?
    dynamic var body : String?
    
    
}
class GuestServiceResponse: Object {
    
    dynamic var id = 0
    var guest = List<GuestObject>()

    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(array : [Any]){
        self.init()
        for x in array {
            let guestObject = GuestObject()
            var dict = x as! Dictionary<String,Any>
            guestObject.id = String("\(dict["id"]!)") ?? " "
            guestObject.title = dict["title"] as? String ?? " "
            guestObject.subtitle = dict["subtitle"] as? String ?? " "
            guestObject.node_type = dict["node_type"] as? String ?? " "
            let pictDict = dict["picture"] as? Dictionary<String,Any> ?? nil
            if pictDict == nil {
                guestObject.picture = " "
            }else{
                let jsonData: Data = try! JSONSerialization.data(withJSONObject: pictDict!, options: .prettyPrinted)
                guestObject.picture = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            }
            guestObject.tag = dict["tag"] as? String  ?? " "
            let dataDict = dict["data"] as? Dictionary<String,Any> ?? nil
            if dataDict == nil {
                guestObject.data = " "
            }else{
                let jsonDictData: Data = try! JSONSerialization.data(withJSONObject: dataDict!, options: .prettyPrinted)
                guestObject.data = NSString(data: jsonDictData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            }
            let iconDict = dict["icon"] as? Dictionary<String,Any> ?? nil
            
            if iconDict == nil {
                guestObject.icon = " "
            }else{
                let jsonIconData: Data = try! JSONSerialization.data(withJSONObject: iconDict!, options: .prettyPrinted)
                guestObject.icon = NSString(data: jsonIconData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            }
            
            let displayDict = dict["display_on"] as? Dictionary<String,Any> ?? nil
            if displayDict == nil {
                guestObject.display_on = " "
            }else{
                let jsonDisplayData: Data = try! JSONSerialization.data(withJSONObject: displayDict!, options: .prettyPrinted)
                guestObject.display_on = NSString(data: jsonDisplayData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            }
            if((dict["children"] as! [Any]).count > 0){
                guestObject.children = (dict["children"] as! [Any]).description
            }else{
                guestObject.children = nil
            }
            
            guestObject.start_time = dict["start_time"] as? String ?? " "
            guestObject.end_time = dict["end_time"] as? String ?? " "
            guestObject.weekday_frequency = dict["weekday_frequency"] as? String ?? " "
            guestObject.type = dict["type"] as? String ?? " "
            guestObject.body = dict["body"] as? String ?? " "
            self.guest.append(guestObject)
        }
    }
    
    public func saveToRealm(){
        let newData : GuestServiceResponse = GuestServiceResponse()
        newData.guest = guest
        // Insert from NSData containing JSON
        let realm = try! Realm()
        
        try! realm.write {
            print("*** Saved Guest Service Response to Database ***")
            realm.add(newData, update: true)
        }
    }
    
    public func loadFromRealm() -> GuestServiceResponse{
        let realm = try! Realm()
        let guest = realm.object(ofType: GuestServiceResponse.self, forPrimaryKey: 0)
        print("*** Load Guest Service Response From Database ***")
        return guest!
    }
    
    public func clearFromRealm(){
        
    }
}
