//
//  OkkamiMain.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/7/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
/*
protocol JSONAble {}

extension JSONAble {
    func toDict() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                if child.value is Array<CalendarBible> {
                    var array = child.value
                    var myNewDictArray = [[String:Any]]()
                    var myNewArray = [String:Any]()
                    for object in array as! [CalendarBible] {
                        myNewArray = object.toDict()
                        myNewDictArray.append(myNewArray)
                    }
                    dict[key] = myNewDictArray
                    
                }else{
                    dict[key] = child.value
                }
            }
        }
        return dict
    }
    
    func toDict(child : Array<CalendarBible>) -> Any{
        var myNewDictArray = [[String:Any]]()
        for childs in child{
            myNewDictArray.append(childs.toDict())
        }
        return myNewDictArray
    }
}

struct CalendarBible: Mappable, JSONAble {
    
    let colour: String
    let rank: String
    
    
    init(map: Mapper) throws {
        try colour = map.from("colour")
        try rank = map.from("rank")
    }
    
}

struct Dates: Mappable, JSONAble {
    
    let date: String
    let season: String
    let season_week: Int
    let weekday : String
    let celebrations : [CalendarBible]
    
    init(map: Mapper) throws {
        try date = map.from("date")
        try season = map.from("season")
        try season_week = map.from("season_week")
        try celebrations = map.from("celebrations")
        try weekday = map.from("weekday")
    }
    
}

//tes realm
class CalendarRealm: Object {
    dynamic var id = 0
    dynamic var colour: String = ""
    dynamic var rank: String = ""
    override class func primaryKey() -> String? {
        return "id"
    }
}

class Bible: Object {
    dynamic var id = 0
    dynamic var date: String = ""
    dynamic var season: String = ""
    dynamic var season_week: Int = 0
    let celebrations = List<CalendarRealm>()
    dynamic var weekday: String = ""
    override class func primaryKey() -> String? {
        return "id"
    }
    
}

@objc public class RCTOkkamiMain: NSObject {
    
    var items = [String]()
    let disposeBag = DisposeBag()
    let bib = Bible()
    var provider: RxMoyaProvider<GitHub>!
    
    public class func newInstance() -> RCTOkkamiMain {
        return RCTOkkamiMain()
    }
    
    public func preConnect(){
        var sessionIns = FGSession.newInstance()
        print("Session Core URL : ", sessionIns.coreURL)
        sessionIns.requestPreconnectInfoIfNeeded()
    }
    
    public func postToken(){
        var setup = FGPublicFunction.newInstance()
        setup.setupRealm()
        var httpIns = FGHTTP.newInstance()
        httpIns.postTokenWithClientID(client_id: "491d83be1463e39c75c2aeda4912119a17f8693e87cf4ee75a58fa032d67f388", client_secret: "4c3da6ab221dc68189bfc4e34631f5cf79d1898153161f28cc084cfd6d69ea82") { (FGAppToken) in
            FGAppToken.saveToRealm()
        }
        
    }
    
    public func getBible(completion: @escaping (_ bible: Any) -> Void) {
        provider = RxMoyaProvider<GitHub>()
        var dict : Any? = ""
        provider.request(.bible).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    dict = try response.mapJSON()
                    completion(dict)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
    }
    public func setupRealm(completion:@escaping(_ realm : Any) -> Void) {
        SyncUser.logIn(with: .usernamePassword(username: "michael.santoso@okkami.com", password: "Mitacantikbanget1", register: false), server: URL(string: "http://127.0.0.1:9080")!) { user, error in
            guard let user = user else {
                fatalError(String(describing: error))
            }
            
            DispatchQueue.main.async {
                // Get the default Realm
                var realm = try! Realm()
                
                // Open Realm
                let configuration = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://127.0.0.1:9080/~/rctokkamisdk")!)
                )
                realm = try! Realm(configuration: configuration)
                completion(realm)
            }
        }
    }
    
    public func setupRealm() -> Void{
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("rctokkamisdk.realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    public func setupRx(completion: @escaping (_ bible : Any) -> Void) {
        self.setupRealm()
        self.provider = RxMoyaProvider<GitHub>()
        //var dict : Any? = ""
        self.provider.request(.bible).subscribe { event in
            switch event {
            case let .next(response):
                //image = UIImage(data: response.data)
                do{
                    let dict = try response.mapJSON()
                    //let dates = response.mapObjectOptional(type: Dates.self)
                    //try print("Dict is : ", response)
                    //let dict = try response?.toDict()
                    /*self.bib.date = dict!["date"] as! String
                     let arrayOfCelebrations = [dict?["celebrations"]]
                     var i : Int = 0
                     for object in arrayOfCelebrations {
                     let cal = CalendarRealm()
                     let dick = object as! Array<Dictionary<String, Any>>
                     cal.colour = dick[i]["colour"]! as! String
                     cal.rank = dick[i]["rank"]! as! String
                     self.bib.celebrations.append(cal)
                     i += 1
                     }
                     
                     // Get the default Realm
                     var realm = try! Realm()
                     
                     self.bib.season = dict!["season"] as! String
                     self.bib.season_week = dict!["season_week"] as! Int
                     self.bib.weekday = dict!["weekday"] as! String
                     */
                    // Persist your data easily
                    /*try! realm.write {
                     realm.add(self.bib)
                     }*/
                    // Get the default Realm
                    var realm = try! Realm()
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                    
                    // Insert from NSData containing JSON
                    try! realm.write {
                        let json = try! JSONSerialization.jsonObject(with: jsonData, options: [])
                        print(json);
                        realm.create(Bible.self, value: json, update: true)
                    }
                    
                    completion(dict)
                    
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
            }.dispose()
        
    }
    
    /*public func testEvent( eventName: String ) {
     self.bridge.eventDispatcher.sendAppEventWithName( eventName, body: "Woot!" )
     }*/
    
}

*/
/*self.getBible(completion: {(bible: Any) -> Void in
 // This is the callback.  It's a closure, passed as the argument to the sketch function's completion parameter
 
 // Ask the end-user if they'd like to view the completed animation now...
 // You as a develoepr have access to the completed animation through the animation parameter to this closure
 print(bible)
 
 })
 */
//return dict



/*DispatchQueue.main.async {
 
 }*/

/*provider.request(.bible).mapArray(type: CalendarBible.self, keyPath: "celebrations").subscribe { event in
 switch event {
 case let .next(response):
 //image = UIImage(data: response.data)
 do{
 //try print("Responsnya adalah : ", response.mapJSON())
 try print("Response is : ", response)
 }catch {
 print("Something wrong");
 }
 case let .error(error):
 print(error)
 default:
 break
 }
 }*/

/*provider.request(.bible).mapObjectOptional(type: Dates.self).subscribe { event in
 switch event {
 case let .next(response):
 //image = UIImage(data: response.data)
 do{
 try print("Response Map Object is : ", response)
 }catch {
 print("Something wrong");
 }
 case let .error(error):
 print("Error Map Object : ",error)
 default:
 break
 }
 }*/
