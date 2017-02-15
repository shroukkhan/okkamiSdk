//
//  FGRoom.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class FGRoom: FGEntity {
    
    /** Room Number */
    var number : NSString? = nil
    
    /** Name of the person who the room is reserved under */
    var reservationName : NSString? = nil
    
    /** Last name of the person who the room is reserved under */
    var lastName : NSString? = nil
    
    /** FGDeviceGroup objects representing ALL groups in the room, sorted by name in ascending order. */
    var allGroups : Array<FGEntity>? = nil
    
    /** FGDeviceGroup objects representing groups that has guest's phone uid,
     sorted by name in ascending order. There could be more than one group. */
    var guestDeviceGroups : Array<FGEntity>? = nil
    
    /** FGDevice objects, sorted by uid in ascending order. */
    var allDevices : Array<FGEntity>? = nil
    
    /** parent entity. */
    var parent : FGEntity?{
        get{
            return self.property
        }
    }
    
    /** Room conversation manager. This is automatically created/removed when room is connected/disconnected, respectively. */
    //dynamic var conversationManager : FGConversationManager? = nil
    
    /** Shopping cart manager. This is nil by default. */
    //dynamic var shoppingCartManager : FGShoppingCartManager? = nil
    
    /** Spa reservation manager. This is nil by default. */
    //dynamic var spaReservationManager : FGSpaReservationManager? = nil
    
    /** The folio is the object that manages items charged to a room */
    //dynamic var folio : FGFolio? = nil
    
    public func getParent() -> FGEntity?{
        return self.property
    }
    
    public func mergeWithDictionary(dict : Dictionary<String, Any>){
        self.identifier = dict["room_id"] as! NSNumber
        self.number = dict["number"] as! NSString
        var checkedIn = dict["checked_in"] as! Dictionary<String,Any>
        self.reservationName = checkedIn["reservation_name"] as! NSString
        self.lastName = checkedIn["last_name"] as! NSString
        var mdDeviceUIDs : Dictionary<String,Any>?
        var allGroupNames : Array<Any>?
        var g = dict["groups"] as! [Any]
    
        //read group and its component UIDs
        /*for (key, devices) in g{
            var mDevices : Array<Any>?
            for uid in devices {
                mDevices?.append(uid as! NSString)
            }
            allGroupNames?.append(g["name"])
            mdDeviceUIDs?.updateValue(mDevices, forKey: g["name"] as! String)
        }*/
        
        //create FGGroup and FGDevice
        var mGroups : Array<Any>?
        var mDevices: Array<Any>?
        
        /*
        var devices = dict["devices"] as! Dictionary<String,Any>
        for deviceDict in devices{
            //var d : FGDevice = FGDevice(deviceDict)
        }*/
        
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
            var check = realm.objects(FGRoom.self).count
            if check > 0{
                
            }else{
                realm.add(self, update: true)
            }
        }
        print("*** Saved Room to Database ***")
    }
    
    public override func loadFromRealm() -> FGRoom{
        var realm = try! Realm()
        var room = realm.object(ofType: FGRoom.self, forPrimaryKey: 0)!
        print("*** Load Room from Database ***")
        return room
    }
    
    public override func clearFromRealm(){
        var realm = try! Realm()
        try! realm.write {
            let deletedObject = realm.objects(FGRoom.self).first
            let deletedAuth = realm.objects(FGAuth).filter("type == 'Device'").first
            let deletedConnect = realm.objects(FGConnect).first
            realm.delete(deletedObject!)
            realm.delete(deletedAuth!)
            realm.delete(deletedConnect!)
        }
        print("*** Clear Room from Database ***")
    }
    */
    
}
