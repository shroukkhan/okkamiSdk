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
    
    var coreURL : URL = URL(string: "https://api.fingi.com")!
    var assetsURL : URL = URL(string: "https://s3.amazonaws.com/fingi/")!
    var hubURL : URL = URL(string: "https://hub.fingi.com")!
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
            //FGLogInfoWithClsName("selectedEntity change -> %@", selectedEntity)
            //_selectedEntity.cancelAllDataManagers()
            //_selectedEntity.suspendAllDataManagers(true)
            _selectedEntity = newValue
            //_selectedEntity.suspendAllDataManagers(false)
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
    
    override init() {
        super.init()
        
        FGSession.setupSecureUserDefaults()
        //FGSession.registerCustomFonts()
        
        #if TARGET_IPHONE_SIMULATOR
            //We'd really like to have consistent UDIDs between sessions while testing on the simulator
            var cachedUDID: String? = UserDefaults.standard.string(forKey: "FGCachedSimulatorUDID")
            if (cachedUDID?.characters.count ?? 0) {
                FGSession.overrideUDID = cachedUDID
            }
            else {
                UserDefaults.standard.set(self.udid, forKey: "FGCachedSimulatorUDID")
                UserDefaults.standard.synchronize()
                //FGLogInfoWithClsAndFuncName("Saving UDID value: %@", self.udid)
            }
        #else
            //FGLogInfoWithClsAndFuncName("UDID is %@", self.udid)
        #endif
        #if TARGET_OS_IPHONE
            // Subscribe to app events
            NotificationCenter.default.addObserver(self, selector: #selector(self.clearMemory), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        #endif
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func clearMemory() {
        let c: FGCompany? = self.selectedEntity?.company
        //FGLogInfoWithClsAndFuncName("Memory Warning Received. Clearing memory of company:\n%@", c)
        if c == nil {
            return
        }
        self.recursivelyResetAllDataManagersOf(c!)
        //FGLog.shared().clearLogs()
        // TODO: do something else to purge memory
    }
    
    func recursivelyResetAllDataManagersOf(_ entity: FGEntity) {
        if self.selectedEntity?.isEqual(entity) == false {
            // don't clear self.selectedEntity
            //entity.resetAllDataManagers()
        }
        /*for e: FGEntity in entity.children {
            self.recursivelyResetAllDataManagersOf(e)
        }*/
    }
    
    class func customFontNames() -> [Any] {
        return ["ClanOT-Book", "ClanOT-CondNews", "ClanOT-NarrMedium", "ClanOT-NarrNews", "ClanOT-News", "ClanOT-UltraItalic"]
    }
    
    class func setupSecureUserDefaults() {
        // Never store the secret somewhere on your file system or in your user preferences but instead put it somewhere static in your code.
        // Preferably use a salt string in combination with something device specific (such as NSUUID's UUIDString method).
        let salt: String = "DrJPGsiaF086ZzkRqBYeBmGQfxKwjzANovZP3YvmHxDEXsomtP"
        var uuid: String
        #if TARGET_IPHONE_SIMULATOR
            //We'd really like to have consistent UDIDs between sessions while testing on the simulator
            var cachedUDID: String? = UserDefaults.standard.string(forKey: "FGCachedSimulatorUDID")
            if (cachedUDID?.characters.count ?? 0) {
                uuid = cachedUDID
            }
            else {
                uuid = UIDevice.current.identifierForVendor.uuidString
            }
        #else
            uuid = UIDevice.current.identifierForVendor!.uuidString
        #endif
        var secret: String = salt + uuid
        //UserDefaults.standard.secret = secret
        UserDefaults.standard.synchronize()
    }
    
    static var overrideUDID: String?{
        get{
            return self.overrideUDID
        }set{
            self.overrideUDID = newValue
            //FGLogInfoWithClsAndFuncName("UDID overridden to %@", udid)
        }
    }
    
    
    /*func udid() -> String {
        var udid: String
        // return the override one if exist
        if (overrideUDID is String) && overrideUDID.length > 0 {
            udid = overrideUDID
        }
        else {
            udid = UIDevice.current.identifierForVendor.uuidString
        }
        return udid
    }*/

    /*class func registerCustomFonts() {
        UIFont.familyNames
        // ------------
        var allRegestered: Bool = true
        UIFont.familyNames
        // ------------
        for f in FGSession.customFontNames() {
            var fontPath: String? = Bundle.fingiSDK().path(forResource: f, ofType: "otf")
            if fontPath != nil {
                var inData = Data(contentsOfFile: fontPath)
                var error: CFErrorRef
                var provider: CGDataProviderRef? = CGDataProviderCreateWithCFData((inData as? CFDataRef))
                var font: CGFontRef = CGFont(provider)
                if CTFontManagerRegisterGraphicsFont(font, error) {
                    //FGLogVerbose(@"Register font [OK]: %@", f); // printing all fonts is too much
                }
                else {
                    allRegestered = false
                    var errorDescription: CFString = CFErrorCopyDescription(error)
                    FGLogWarn("Register font [ERROR] %@: %@", errorDescription, f)
                }
            }
            else {
                FGLogWarn("Register font [ERROR] File not found: %@", f)
            }
        }
        if allRegestered {
            FGLogVerbose("Register fonts [OK]")
        }
    }
    
    class func unregisterCustomFonts() {
        for f: String in FGSession.customFontNames() {
            var fontPath: String? = Bundle.fingiSDK().path(forResource: f, ofType: "otf")
            var inData = Data(contentsOfFile: fontPath)
            var error: CFErrorRef
            var provider: CGDataProviderRef? = CGDataProviderCreateWithCFData((inData as? CFDataRef))
            var font: CGFontRef = CGFont(provider)
            if !CTFontManagerUnregisterGraphicsFont(font, error) {
                var errorDescription: CFString = CFErrorCopyDescription(error)
                FGLogWarn("Failed to unregister font: %@", errorDescription)
            }
        }
    }*/
    
    func addAndChangeSelectEntity(with line: FGEntityLine) {
        if (line.isKind(of: FGEntityLine.self)) == false {
            //FGLogErrorWithClsAndFuncName("cannot change to entity line %@", line)
            return
        }
        // can't check yet because preset is not loaded at launch
        //    if ([FGSession shared].selectedEntity.presets.isEntitySelectionEnabled == NO) {
        //        return;
        //    }
        
        // Add line to existing company.
        //self.selectedEntity?.company.addNewEntities(from: line)
        // Get the ending of the line we just added.
        //var ending: FGEntity? = self.selectedEntity?.company.getEndingEntityOf(line)
        //if ending == nil {
            //FGLogErrorWithClsAndFuncName("ending entity in line: %@ not found in company: %@", line, self.selectedEntity.company)
            //return
        //}
        //self.selectedEntity = ending
    }
    
}
