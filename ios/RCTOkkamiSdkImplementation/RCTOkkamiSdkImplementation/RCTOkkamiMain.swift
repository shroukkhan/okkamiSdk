//
//  RCTOkkamiMain.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 12/29/16.
//  Copyright © 2016 michaelabadi.com. All rights reserved.
//
import UIKit
import Foundation
import Moya
import Moya_ModelMapper
import UIKit
import RxCocoa
import RxSwift
import Mapper
import RealmSwift
import Realm

@objc public class RCTOkkamiMain: NSObject {
    
    //Initializer
    public class func newInstance() -> RCTOkkamiMain {
        return RCTOkkamiMain()
    }
    
    /**------------------------------------------------------------ OLD CORE -------------------------------------------------------------**/
    
    public func setupRealm(){
        var setup = FGPublicFunction.newInstance()
        setup.setupRealm()
    }
    
    public func migration(){
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        
        config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    public func preConnect(){
        
        /*var config = Realm.Configuration()
        var schemaVer = try! schemaVersionAtURL(config.fileURL!)
        // Use the default directory, but replace the filename with the username
        
        config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: schemaVer + 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 2) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config*/
        
        //check preconn save data first
        /*var realm = try! Realm()
        var checkPrec = realm.objects(FGPreconnect).count
        if checkPrec > 0 {
            print("No need to preconn")
        }else{
            
            //check session from database if not found then create new one
            var realm = try! Realm()
            var checkSes = realm.objects(FGSession).count
            var sessionIns = FGSession()
            if checkSes > 0 {
                sessionIns = sessionIns.loadFromRealm()
            }else{
                sessionIns.coreURL = "https://api.fingi-staging.com"
                sessionIns.saveToRealm()
            }
            
            //call preconn using saved UDID
            var httpIns = FGHTTP()
            httpIns.postPreconnectAuthWithUID(uid: sessionIns.UDID) { (callback) in
                callback.saveToRealm()
            }
        }*/
    }
    
    public func connectToRoom(room: String, token: String){
        
        /*var httpIns = FGHTTP.newInstance()
        var preconn = FGPreconnect.init()
        preconn = preconn.loadFromRealm()
        httpIns.postConnectToRoom(name: room, tokenRoom: token, uid: preconn.uid as String, preconnect: preconn, property_id: "3") { (callback) in
            callback.saveToRealm()
        }*/
    }
    
    public func disconnectFromRoom(){
        /*var httpIns = FGHTTP.newInstance()
            
        //check room from realm
        var room = FGRoom.init()
        room = room.loadFromRealm()

        httpIns.postDisconnectToRoom(room: room) { (callback) in
            callback.clearFromRealm()
            print("*** Disconnected From Room ***")
        }*/
        
    }
    
    /**------------------------------------------------------------ NEW CORE -------------------------------------------------------------**/
    
    public func postToken(){
        //setupRealm()
        /*var httpIns = FGHTTP.newInstance()
        httpIns.postTokenWithClientID(client_id: "491d83be1463e39c75c2aeda4912119a17f8693e87cf4ee75a58fa032d67f388", client_secret: "4c3da6ab221dc68189bfc4e34631f5cf79d1898153161f28cc084cfd6d69ea82") { (FGAppToken) in
            FGAppToken.saveToRealm()
        }*/
        
    }

}
