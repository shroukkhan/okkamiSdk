//
//  FGSession.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/4/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class FGSession: NSObject {
    
    var coreURL : NSString = "https://api.fingi.com"
    var assetsURL : NSString = "https://s3.amazonaws.com/fingi/"
    var hubURL : NSString = "https://hub.fingi.com"
    var hubPort : NSInteger = 20020
    var allowShowingAlertViews : Bool = true
    var enableSIPAutoConnectFromCurrentPresets : Bool = true
    var UDID : NSString = UIDevice.current.identifierForVendor!.uuidString as NSString
    private var _selectedEntity : FGEntity?
    
    var selectedEntity : FGEntity? {
        get{
            return _selectedEntity
        }
        set{
            _selectedEntity = newValue
        }
    }
    
    static let sharedInstance: FGSession = { FGSession() }()
    /*public func saveToRealm(){
        var newData : FGSession = FGSession()
        newData.coreURL = coreURL
        newData.assetsURL = assetsURL
        newData.hubURL = hubURL
        newData.hubPort = hubPort
        newData.allowShowingAlertViews = allowShowingAlertViews
        newData.enableSIPAutoConnectFromCurrentPresets = enableSIPAutoConnectFromCurrentPresets
        newData.UDID = UDID

        var realm = try! Realm()
        
        try! realm.write {
            realm.add(newData, update: true)
        }
    }
    
    public func loadFromRealm() -> FGSession{
        var realm = try! Realm()
        let session = realm.object(ofType: FGSession.self, forPrimaryKey: 0)
        return session!
    }
    
    public func clearFromRealm(){
        
    }*/
    
    //var preconnect : FGPreconnect = FGPreconnect().loadFromRealm()
    //dynamic var paranetCRM : FGParanetCRM = FGParanetCRM()
    /*private var _selectedEntity : FGEntity?
    var selectedEntity : FGEntity? {
        get{
            return _selectedEntity
        }
        set{
            _selectedEntity = newValue
        }
    }*/
    //dynamic var brand : FGBrand = FGBrand()
    //static let sharedInstance: FGSession = { FGSession() }()
    
    /*public class func newInstance() -> FGSession {
        return FGSession()
    }*/
    
    /*public func requestPreconnectInfoIfNeeded(){
        //check saved data first
        //not yet
        
        //request new preconnect and save it
        var newHttp = FGHTTP.sharedInstance
        newHttp.postPreconnectAuthWithUID(uid: FGSession.sharedInstance.UDID) { (callback) in
            callback.saveToRealm()
        }

    }*/
    
}
