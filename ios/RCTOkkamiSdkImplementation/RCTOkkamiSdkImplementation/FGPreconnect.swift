//
//  FGPreconnect.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/4/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//
import UIKit
import Foundation
import RealmSwift
import Realm

class FGPreconnect: NSObject, NSCoding {
    
    var identifier : NSString = ""
    var guest_id : NSString = ""
    var uid : NSString = ""
    var auth : FGAuth?
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        var guestDeviceDict : NSDictionary = dictionary["guest_device"] as! NSDictionary
        identifier = guestDeviceDict["id"] as! NSString
        if ((guestDeviceDict["guest_id"] as? NSString) != nil) {
            guest_id = guestDeviceDict["guest_id"] as! NSString
        }else{
            guest_id = ""
        }
        uid = guestDeviceDict["uid"] as! NSString
        var authDict : NSDictionary = guestDeviceDict["authentication"] as! NSDictionary
        auth = FGPreconnectAuth(token: authDict["auth_token"] as! NSString, secret: authDict["auth_secret"] as! NSString)
    }
    
    convenience required init(preconnResp : PreconnectResponse) {
        self.init()
        self.identifier = preconnResp.identifier
        self.guest_id = preconnResp.guest_id
        self.uid = preconnResp.uid
        self.auth = FGAuth(token: preconnResp.auth!.token, secret: preconnResp.auth!.secret)
    }
    
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        
        identifier = aDecoder.decodeObject(forKey: "identifier") as! NSString
        guest_id = aDecoder.decodeObject(forKey: "guest_id") as! NSString
        uid = aDecoder.decodeObject(forKey: "uid") as! NSString
        
        var data : NSData = aDecoder.decodeObject(forKey: "auth") as! NSData
        do {
            try auth = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! FGAuth
        } catch (exception() as! NSException) as! Realm.Error {
            auth = FGAuth(token: "", secret: "")
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(guest_id, forKey: "guest_id")
        aCoder.encode(uid, forKey: "uid")
        var data : NSData = NSKeyedArchiver.archivedData(withRootObject: auth) as NSData
        aCoder.encode(data, forKey: "auth")
    }
    
    /*public func saveToRealm(){
        var newData : FGPreconnect = FGPreconnect()
        newData.identifier = identifier
        newData.guest_id = guest_id
        newData.uid = uid
        newData.auth = auth
        newData.id = 0
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        
        try! realm.write {
            var checkPrec = realm.objects(FGPreconnect).count
            if checkPrec > 0{
                var test = realm.objects(FGAuth).filter("type == %@", "Preconnect").count
                if test > 0{
                    
                }else{
                    print("*** Saved Preconnect to Database ***")
                    realm.add(newData, update: true)
                }
            }else{
                print("*** Saved Preconnect to Database ***")
                realm.add(newData, update: true)
            }
        }
    }
    
    public func loadFromRealm() -> FGPreconnect{
        var realm = try! Realm()
        let preconnect = realm.object(ofType: FGPreconnect.self, forPrimaryKey: 0)
        print("*** Load Preconnect From Database ***")
        return preconnect!
    }
        
    public func clearFromRealm(){
        
    }*/
}
