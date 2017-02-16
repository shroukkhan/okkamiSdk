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

    var _preconnect : FGPreconnect?
    var preconnect : FGPreconnect? {
        get{
            return _preconnect
        }
        set{
            _preconnect = newValue
        }
    }
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
