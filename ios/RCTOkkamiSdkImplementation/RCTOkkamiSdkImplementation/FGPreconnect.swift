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
        let guestDeviceDict : NSDictionary = dictionary["guest_device"] as! NSDictionary
        identifier = guestDeviceDict["id"] as! NSString
        if ((guestDeviceDict["guest_id"] as? NSString) != nil) {
            guest_id = guestDeviceDict["guest_id"] as! NSString
        }else{
            guest_id = ""
        }
        uid = guestDeviceDict["uid"] as! NSString
        let authDict : NSDictionary = guestDeviceDict["authentication"] as! NSDictionary
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
        
        let data : NSData = aDecoder.decodeObject(forKey: "auth") as! NSData
        do {
            try auth = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? FGAuth
        } catch (exception() as! NSException) as! Realm.Error {
            auth = FGAuth(token: "", secret: "")
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(guest_id, forKey: "guest_id")
        aCoder.encode(uid, forKey: "uid")
        let data : NSData = NSKeyedArchiver.archivedData(withRootObject: auth!) as NSData
        aCoder.encode(data, forKey: "auth")
    }
}
