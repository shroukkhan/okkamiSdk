//
//  FGProperty.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class FGProperty: FGMailboxEntity {
    
    /** Property TV genres. Its object will be an array of FGTVGenre objects.
     This is has `autoRefreshDuration` set to 1800 (30 minutes). */
    var tvGenresDM: FGDataManager!
    /** Weather Forecast. Its object will be an FGWeather objects. */
    var weatherDM: FGDataManager!
    
    /** parent entity. */
    var parent : FGEntity?{
        get{
            return self.brand
        }
    }
    public func getParent() -> FGEntity?{
        return self.brand
    }
    
    convenience required init(identifier: NSString) {
        self.init()
        self.identifier = identifier
        self.room = FGRoom(identifier: "0")
        self.room?.property = self
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as? NSString
    }
    
    /*override var allDataManagers: [Any]? {
        get{
            if self.tvGenresDM == nil {
                self.tvGenresDM = FGDataManager(delegate: self as! FGDataManagerDelegate)
                self.tvGenresDM.autoRefreshDuration = 1800
            }
            if self.weatherDM == nil {
                self.weatherDM = FGDataManager(delegate: self as! FGDataManagerDelegate)
            }
            // must include super objects!
            let new : [Any] = [super.allDataManagers!, self.tvGenresDM!, self.weatherDM]
            return new
        }set{
            self.allDataManagers = newValue
        }
        
    }
    
    override func dataManagerStartLoading(_ dm: FGDataManager) -> NSURLConnection {
        if dm == self.weatherDM {
            return FGHTTP.shared().getWeatherForecastOf(self, location: nil, callback: {(_ weather: FGWeather, _ err: Error) -> Void in
                if !err {
                    dm.object = weather
                }
                dm.error = err
            })
        }
        else if dm == self.tvGenresDM {
            // request TV Genres
            return FGHTTP.shared().getTVGenresOf(self, callback: {(_ arr: [Any], _ err: Error) -> Void in
                if err {
                    dm.error = err
                    // setting error also sets dm state
                }
                else {
                    dm.object = arr
                    // trigger observer (1st time)
                    var theCallBack: ((_: [Any], _: Error) -> Void)?? = {(_ arr: [Any], _ err: Error) -> Void in
                        if !err {
                            dm.willChangeValue(forKey: "object")
                            // trigger observer (2nd time)
                            for gr: FGTVGenre in dm.object?.toNSArray() {
                                FGTVChannel.channelArray(gr.channels, mergeEPGFromArray: arr)
                            }
                            dm.didChangeValue(forKey: "object")
                        }
                        dm.error = err
                    }
                    // request TV EPG, nestedly
                    if self.presets.hardcodedEPGMode {
                        FGHTTP.shared().getHardcodedEPG(fromFile: nil, callback: theCallBack)
                        dm.connection = nil
                    }
                    else {
                        dm.connection = FGHTTP.shared().getTVEPGOf(self, callback: theCallBack)
                    }
                }
            })
        }
        else {
            // must call super at the end!
            return super.dataManagerStartLoading(dm)
        }
    }*/
    
    
    /*public override func saveToRealm(){
        
        // Insert from NSData containing JSON
        var realm = try! Realm()
        try! realm.write {
            var check = realm.objects(FGProperty.self).count
            if check > 0{
                var checkRoom = realm.objects(FGRoom.self).count
                if checkRoom > 0{
                    
                }else{
                    realm.add(self, update: true)
                }
            }else{
                realm.add(self, update: true)
            }
        }
        print("*** Saved Property to Database ***")
    }
    
    public override func loadFromRealm() -> FGProperty{
        var realm = try! Realm()
        var property = realm.object(ofType: FGProperty.self, forPrimaryKey: 0)!
        print("*** Load Property from Database ***")
        return property
    }
    
    public override func clearFromRealm(){
        var realm = try! Realm()
        try! realm.write {
            //let deletedObject = realm.objects(FGProperty.self).filter("brand == \(self.brand)")
            let deletedObject = realm.objects(FGProperty.self).first
            realm.delete(deletedObject!)
        }
        print("*** Clear Property from Database ***")
    }*/
    
}
