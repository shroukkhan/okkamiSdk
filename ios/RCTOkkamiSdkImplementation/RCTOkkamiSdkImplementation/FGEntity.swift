//
//  FGEntity.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
let FGEntityId_invalid = 0

class FGEntity : NSObject/*, FGDataManagerDelegate*/{
    
    /** Entity name and id **/
    var identifier : NSString?{
        get{
            return self.identifier
        }set{
            self.identifier = newValue
        }
    }
    
    var name : NSString = ""
    
    /** Entity auth. **/
    var auth : FGAuth? = nil
    
    /** Entity room. **/
    var room : FGRoom? = nil
    
    /** Entity property. **/
    var property: FGProperty? = nil
    
    /** Entity brand. **/
    var brand: FGBrand? = nil
    
    /** Entity company. **/
    var company: FGCompany? = nil
    
    /** Room login/connect credentials. **/
    var connect : FGConnect? = nil
    
    /** Presets data manager. Its object will be a FGPresets object.
     A preset object with default values is assigned when receiver is initialized, so it will never be nil. */
    var presetsDM: FGDataManager!
    
    /** Promotions data manager. Its object will be an array of FGPromotionNode objects. */
    var promotionsDM: FGDataManager!
    
    /** Guest services data manager. Its object will be an array of FGNode subclass objects.
     Data is cached and used when no internet connection. */
    var guestServicesDM: FGDataManager!
    
    var allDataManagers: [Any]?{
        get{
            return self.allDataManagers
        }set{
            self.allDataManagers = newValue
        }
    }
    /** Returns the object of `presetsDM`. */
    var presets: FGPresets{
        get{
            return self.presetsDM.object! as! FGPresets
        }
    }
    
    /** Auth token and secret, same as -auth. If nil, it will search through parents. */
    var collapsedAuth: FGAuth!

    required override init() {
        super.init()
    }
    
    required init(dictionary: Dictionary<String, AnyObject>){
        super.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as? NSString
    }
    
    required init(identifier: NSString){
        super.init()
        self.identifier = identifier
        
        // Allow FGRoom's identifier to be 0.
        // For preset and device comparison purpose in FGRoom -respondToHubReloadCommand
        if !(self is FGRoom) {
            //assert(self.identifier != FGEntityId_invalid, "invalid identifier.")
        }
        self.allDataManagers = self.dataManager()
    }
    
    func dataManager()->[Any]{
        // create new data managers
        if self.presetsDM == nil {
            self.presetsDM = FGDataManager(delegate: self as! FGDataManagerDelegate)
            self.presetsDM.object = FGPresets()
            // assign default preset
        }
        if self.promotionsDM == nil {
            self.promotionsDM = FGDataManager(delegate: self as! FGDataManagerDelegate)
        }
        if self.guestServicesDM == nil {
            self.guestServicesDM = FGDataManager(delegate: self as! FGDataManagerDelegate)
        }
        return [self.presetsDM, self.promotionsDM, self.guestServicesDM]
    }
    func objects(withArray array: [Any]) -> [Any] {
        
        var m = [Any]()
        for d in array {
            let e = FGEntity(dictionary: d as! Dictionary<String,AnyObject>)
            m.append(e)
        }
        return [Any](arrayLiteral: m)
    }
    
    public func connectWithObject(connect: FGConnect) {
        
    }
    
    /*func findOf(_ aClass: AnyClass, identifier: Int) -> FGEntity? {
        if (self.isMember(of: aClass)) && (self.identifier as! String) == identifier.description  {
            
        }
        else {
            for e: FGEntity in self.children {
                if (e is aClass) && e.identifier == identifier {
                    return e
                }
                else {
                    var result: FGEntity? = e.findOf(aClass, identifier: identifier)
                    if result != nil {
                        return result!
                    }
                }
            }
            return nil
        }
    }*/
    
    
    func cancelAllDataManagers() {
        for dm in (self.allDataManagers! as [Any]) {
            (dm as! FGDataManager).cancelLoading()
        }
    }
    
    func resetAllDataManagers() {
        for dm in (self.allDataManagers! as [Any]) {
            (dm as! FGDataManager).reset()
        }
    }
    
    func suspendAllDataManagers(_ suspend: Bool) {
        for dm in (self.allDataManagers! as [Any]) {
            (dm as! FGDataManager).isSuspendAutoRefreshing = suspend
        }
    }
    /*func dataManagerStartLoading(_ dm: FGDataManager) -> NSURLConnection {
        if dm == self.promotionsDM {
            return FGHTTP.sharedInstance.getPromotionsOf(self, callback: {(_ arr: [Any], _ err: Error) -> Void in
                if err {
                    //[self showErrorAlert:err title:@"Cannot get Promotions"];
                }
                else {
                    dm.object = arr
                }
                dm.error = err
            })
        }
        else if dm == self.presetsDM {
            return FGHTTP.sharedInstance.getPresetsOf(self, callback: {(_ obj: NSObject, _ err: Error) -> Void in
                if err {
                    //[self showErrorAlert:err title:@"Cannot get Presets"];
                }
                else {
                    dm.object = obj
                    // to start selectPropertyWaitTime if needed
                    UIApplication.shared.sendEvent(UIEvent())
                }
                dm.error = err
            })
        }
        else if dm == self.guestServicesDM {
            var e: FGEntity? = self
            // need e to be room when connected because CORE will filter nodes by connect state,
            // determined by auth token
            return FGHTTP.sharedInstance.getGuestServicesOf(e, checkCache: !FGReachability.isReachable(), callback: {(_ arr: [Any], _ err: Error) -> Void in
                if err {
                    //[self showErrorAlert:err title:@"Cannot get Guest Services"];
                    self.dataManagerStartLoading(dm)
                }
                else {
                    dm.object = arr
                }
                dm.error = err
            })
        }
        else {
            return nil
        }
        
    }*/
    
    class func levelName() -> String? {
        if self.isSubclass(of: FGRoom.self) {
            return "Room"
        }
        else if self.isSubclass(of: FGProperty.self) {
            return "Property"
        }
        else if self.isSubclass(of: FGBrand.self) {
            return "Brand"
        }
        else if self.isSubclass(of: FGCompany.self) {
            return "Company"
        }
        else {
            return nil
        }
        
    }
    
    func levelName() -> String? {
        return self.self.levelName()
    }
    
    func pathComponentName() -> String? {
        if (self is FGRoom) {
            return "rooms"
        }
        else if (self is FGProperty) {
            return "properties"
        }
        else if (self is FGBrand) {
            return "brands"
        }
        else if (self is FGCompany) {
            return "companies"
        }
        else {
            return nil
        }
        
    }
    
    func pathComponent() -> String {
        var str: String = ""
        var name: String = self.pathComponentName()!
        var id: String = self.identifierString()
        if (name.characters.count > 0) && (id.characters.count > 0) {
            str = URL(fileURLWithPath: str).appendingPathComponent(name).absoluteString
            str = URL(fileURLWithPath: str).appendingPathComponent(id).absoluteString
        }
        return str
    }
    
    func pathComponentWithParents() -> String {
        var str: String = ""
        str = URL(fileURLWithPath: self.pathComponent()).appendingPathComponent(str).absoluteString
        if self.isKind(of: FGRoom.self) {
            let me = self as! FGRoom
            str = URL(fileURLWithPath: (me.parent?.pathComponentWithParents())!).appendingPathComponent(str).absoluteString
        }else if self.isKind(of: FGBrand.self){
            let me = self as! FGBrand
            str = URL(fileURLWithPath: (me.parent?.pathComponentWithParents())!).appendingPathComponent(str).absoluteString
        }else if self.isKind(of: FGProperty.self){
            let me = self as! FGProperty
            str = URL(fileURLWithPath: (me.parent?.pathComponentWithParents())!).appendingPathComponent(str).absoluteString
        }
        return str
    }
    
    func findParentEntityOf(_ aClass: AnyClass) -> FGEntity? {
        if self.isKind(of: FGRoom.self) {
            let me = self as! FGRoom
            if (me.parent != nil) {
                if (me.parent!.isKind(of: aClass)) {
                    return me.parent!
                }
                else {
                    return me.parent!.findParentEntityOf(aClass)
                }
            }
            else {
                return nil
            }
        }else if self.isKind(of: FGBrand.self){
            let me = self as! FGBrand
            if (me.parent != nil) {
                if (me.parent!.isKind(of: aClass)) {
                    return me.parent!
                }
                else {
                    return me.parent!.findParentEntityOf(aClass)
                }
            }
            else {
                return nil
            }
        }else if self.isKind(of: FGProperty.self){
            let me = self as! FGProperty
            if (me.parent != nil) {
                if (me.parent!.isKind(of: aClass)) {
                    return me.parent!
                }
                else {
                    return me.parent!.findParentEntityOf(aClass)
                }
            }
            else {
                return nil
            }
        }
        return nil
    }
    
    /*func children(withKindOf aClass: AnyClass, recursive: Bool) -> [Any] {
        var m = [Any]()
        for child: FGEntity in self.children {
            if child != nil && (child is aClass) {
                m.append(child)
                if recursive {
                    m += child.children(withKindOf: aClass, recursive: true)
                }
            }
        }
        return [Any](arrayLiteral: m)
    }*/
    
    func roomOrRoomOfProperty() -> FGRoom? {
        if (self is FGRoom) {
            return (self as? FGRoom)!
        }
        else if (self is FGProperty) {
            return (self as? FGProperty)!.room!
        }
        else {
            return nil
        }
        
    }
    
    override var description: String {
        return "[<\(self)> (\(self)) ID:\(self.identifierString) name:\(self.name)]"
    }
    
    func prettyDescriptionWithoutChildren() -> String {
        return "\(self.self.levelName()) ID: \(self.identifierString)"
    }
    
    /*func prettyDescriptionWithParents() -> String {
        if self.parent {
            return "\(self.parent?.prettyDescriptionWithParents()), \(self.prettyDescriptionWithoutChildren())"!
        }
        else {
            return self.prettyDescriptionWithoutChildren()
        }
    }*/
    
    func findConversationManager() -> FGConversationManager {
        let cm: FGConversationManager? = nil
        /*if (self is FGRoom) {
            cm = (self as? FGRoom)?.conversationManager
        }
        else if (self is FGMailboxEntity) {
            cm = (self as? FGMailboxEntity)?.conversationManager
        }*/
        
        return cm!
    }
    
    func identifierString() -> String {
        return "\(self.identifier)"
    }
    /** Translate type string to class */
    
    func getClass(fromNodeEntityType type: String) -> AnyClass? {
        if type.isEqual(toStringCaseInsensitive: "company") {
            return FGCompany.self
        }
        else if type.isEqual(toStringCaseInsensitive: "brand") {
            return FGBrand.self
        }
        else if type.isEqual(toStringCaseInsensitive: "property") {
            return FGProperty.self
        }
        else {
            return nil
        }
        
    }
    // MARK: - equality
    
    func isEqual(to entity: FGEntity) -> Bool {
        let haveSameClass: Bool = type(of: self) === entity.self
        let haveEqualIdentifiers: Bool = self.identifier == entity.identifier
        return haveSameClass && haveEqualIdentifiers
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if self.isKind(of: object as! AnyClass) {
            return true
        }
        return self.isEqual(to: (object as! FGEntity))
    }
    
    override var hash: Int {
        get{
            return self.identifier!.integerValue
        }
    }
    // MARK: convenience
    
    /*func collapsedAuth() -> FGAuth {
        return self.auth ? self.auth : self.parent?.collapsedAuth()!
    }*/
    
    func downToPropertyLevel() -> FGEntity? {
        if (self is FGRoom) {
            let room: FGRoom? = (self as? FGRoom)
            return room!.property!
        }
        else {
            return nil
        }
    }
    
    
}
