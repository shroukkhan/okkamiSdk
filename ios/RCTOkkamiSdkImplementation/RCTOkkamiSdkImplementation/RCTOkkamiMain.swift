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
    
    public func preConnect(){
        
        //check preconn save data first
        let realm = try! Realm()
        let checkPrec = realm.objects(PreconnectResponse.self).count
        if checkPrec > 0 {
            print("No need to preconn")
        }else{
            //call preconn using device UDID
            let httpIns = FGHTTP()
            httpIns.postPreconnectAuthWithUID(uid: FGSession.sharedInstance.UDID) { (callback) in
                callback.saveToRealm()
                print("*** Preconnect Successfully Called ***")
            }
        }
    }
    
    public func connectToRoom(room: String, token: String){
        
        let httpIns = FGHTTP()
        let preconnResp = PreconnectResponse().loadFromRealm()
        let preconn = FGPreconnect(preconnResp: preconnResp)
        httpIns.postConnectToRoom(name: room, tokenRoom: token, uid: preconnResp.uid as String, preconnect: preconn, property_id: "3") { (callback) in
            callback.saveToRealm()
            print("*** Connected to Room ***")
        }
    }
    
    public func disconnectFromRoom(){
        let httpIns = FGHTTP()
            
        //check room from realm
        let roomResp = ConnectRoomResponse().loadFromRealm()
        if (roomResp != nil) {
            let room = FGRoom(connectResp: roomResp!)
            
            httpIns.postDisconnectToRoom(room: room) { (callback) in
                callback.saveToRealm()
                print("*** Disconnected From Room ***")
            }
        }else{
            
        }
    }
    
    public func downloadPresets(force : Bool){
        
        if force {
            let httpIns = FGHTTP()
            
            //take entity from realm
            let roomResp = ConnectRoomResponse().loadFromRealm()
            var entity :FGEntity?
            
            //should check from room -> property -> brand -> company
            if (roomResp != nil) {
                entity = FGRoom(connectResp: roomResp!)
            }
            
            httpIns.getPresetToEntity(entity: entity!) { (callback) in
                callback.saveToRealm()
                print("*** Downloaded Entity Presets ***")
            }
        }else{
            //use realm db preset
        }
    }
    
    public func downloadRoomInfo(force : Bool){
        
        if force {
            let httpIns = FGHTTP()
            //take entity from realm
            let roomResp = ConnectRoomResponse().loadFromRealm()
            var room :FGRoom?
            //check room
            if (roomResp != nil) {
                room = FGRoom(connectResp: roomResp!)
            }
            
            httpIns.getRoomInfo(room: room!, completion: { (callback) in
                callback.saveToRealm()
                print("*** Downloaded Room Info ***")
            })
        }else{
            //use realm db preset
        }
    }
    
    
    public func getGuestService(){
        
        let httpIns = FGHTTP()
        //take entity from realm
        let roomResp = ConnectRoomResponse().loadFromRealm()
        var room :FGRoom?
        //check room
        if (roomResp != nil) {
            room = FGRoom(connectResp: roomResp!)
        }
        
        httpIns.getGuestService(entity: room!) { (callback) in
            callback.saveToRealm()
            print("*** Get Guest Service Success ***")
        }
    }
    
    public func executeCoreRESTCall(apicore: String, apifunc: String, payload : String, secret: String, token: String, completion: @escaping (_ : Any) -> Void){
        
        let httpIns = FGHTTP()
        httpIns.executeCoreRESTCall(apicore: apicore, apifunc: apifunc, payload: payload, secret: secret, token: token) { (callback) in
            print("*** Execute Core REST Call Successfully Called ***")
            completion(callback)
        }
        
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
