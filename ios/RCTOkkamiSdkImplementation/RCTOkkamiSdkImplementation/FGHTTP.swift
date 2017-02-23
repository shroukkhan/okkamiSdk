//
//  APICall.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/4/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import Moya
import Moya_ModelMapper
import UIKit
import RxCocoa
import RxSwift
import Alamofire
import Mapper
import CryptoSwift

class FGHTTP: NSObject, NSURLConnectionDelegate {
    
    static let sharedInstance: FGHTTP = { newInstance() }()
    var disposebag : DisposeBag?
    var provider: RxMoyaProvider<API>!
    var providerNew: RxMoyaProvider<APINew>!
    
    //Payload on progress
    public enum Payload{
        case postPreconnect()
        case postConnect()
        case postDisconnect()
    }
    
    //getPayLoad on Progress
    public func getPayload(param : Payload) -> [String:Any]?{
        switch param {
        case .postConnect():
            return nil
        default:
            return nil
        }
    }

    
    //initializer
    public class func newInstance() -> FGHTTP {
        return FGHTTP()
    }
    
    deinit {
        self.disposebag = nil
    }
    /**------------------------------------------------------------ OPEN FUNCTION -------------------------------------------------------------**/

    //HMAC hash signature
    public func authSignatureWithString(data : String, key : String) -> String{
        let bytes: Array<UInt8> = Array(data.utf8)
        let secKey: Array<UInt8> = Array(key.utf8)
        var hmac = ""
        do {
            hmac = try HMAC(key: secKey, variant: .sha1).authenticate(bytes).toHexString()
        }catch{
            
        }
        return hmac
    }
    
    public func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    /**------------------------------------------------------------ OLD CORE -------------------------------------------------------------**/
    
    //POST device UID to get guest device auth token using Preconnect
    public func postPreconnectAuthWithUID(uid : NSString, completion: @escaping (_ precon : PreconnectResponse) -> Void){
        
        //Set the policies or certificate
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )

        /**to use dynamic base URL
        setBaseURL(baseUrl: "https://api.fingi.com")
        var newUrl = getBaseURL() as! String
        **/
        
        let jsonDict : [String:String] = ["uid":uid as String]
        var data : Data!
        var totalURL : URL!
        do{
            data = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            totalURL = try String("\(API.getBaseURL.baseURL)/v1/preconnect")?.asURL()
            //totalURL = try String("\(newUrl)/v1/preconnect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        let baseURL = totalURL as NSURL
        let timestamp = NSDate().timeIntervalSince1970
        let timestampStr:String = String(format:"%.0f", timestamp)
        var datastring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        datastring = datastring!.replacingOccurrences(of: "\n", with: "")
        datastring = datastring!.replacingOccurrences(of: " ", with: "")
        
        //using company token
        let token = String("Token token=\"32361e1a5a496e0c\", timestamp=\"\(timestampStr)\"")
        
        //finalString to be hashed later
        let finalStr = String("\(baseURL.absoluteString!)\(timestampStr)\(datastring!)")!
        let authSign = authSignatureWithString(data: finalStr, key: "92865cbcd9be8a19d0563006f8b81c73")

        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let defaultEndpoint = RxMoyaProvider.defaultEndpointMapping(target)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        let dispose = self.provider.request(.postPreconnectWithUID(uid as String)).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    print(dict)
                    let preconn : PreconnectResponse = PreconnectResponse(dictionary: dict as! Dictionary<String, AnyObject>)
                    completion(preconn)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
        self.disposebag?.insert(dispose)
        
    }
    
    
    //POST to connect to a room using guest_device auth and property_id.
    public func postConnectToRoom(name: String, tokenRoom: String, uid : String, preconnect : FGPreconnect, property_id : String, completion: @escaping (_ connectResp : ConnectRoomResponse) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        let jsonDict : [String:String] = ["name": name as String, "token": tokenRoom as String, "uid":uid as String, "property_id" : property_id as String, "device_type" : "guest_device", "os" : "ios"]
        var data : Data!
        var totalURL : URL!
        do{
            data = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            totalURL = try String("\(API.getBaseURL.baseURL)/v1/connect")?.asURL()
            //totalURL = try String("\(newUrl)/v1/connect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        let baseURL = totalURL as NSURL
        let timestamp = NSDate().timeIntervalSince1970
        let timestampStr:String = String(format:"%.0f", timestamp)
        var datastring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        datastring = datastring!.replacingOccurrences(of: "\n", with: "")
        datastring = datastring!.replacingOccurrences(of: " ", with: "")
        
        //using preconnect guest_device token
        let auth = FGAuth(token: preconnect.auth!.token, secret: preconnect.auth!.secret)
        let token = String("Token token=\"\(auth.token)\", timestamp=\"\(timestampStr)\"")
        
        //finalString to be hashed later
        let finalStr = String("\(baseURL.absoluteString!)\(timestampStr)\(datastring!)")!
        let authSign = authSignatureWithString(data: finalStr, key: auth.secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let defaultEndpoint = RxMoyaProvider.defaultEndpointMapping(target)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        let dispose = self.provider.request(.postConnectToRoomWithEntity(name, tokenRoom, uid, property_id, "guest_device")).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    print(dict)
                    let connectResp : ConnectRoomResponse = ConnectRoomResponse(dictionary: dict as! Dictionary<String, AnyObject>, name: name as NSString, token: tokenRoom as NSString)
                    var roomDict = (dict as! Dictionary<String, Any>)["room"] as! Dictionary<String, Any>
                    print("*** Connected to property id : \(roomDict["property_id"]!) room id : \(roomDict["room_id"]!) room number : \(roomDict["number"]!) ***" )
                    /*
                    //create the authentication
                    let authenticate : Dictionary<String, Any> = (dict as! Dictionary<String, Any>)["authentication"] as! Dictionary<String, Any>
                    //var auth : FGAuth = FGAuth.authWithToken(token: authenticate["auth_token"] as! NSString, secret: authenticate["auth_secret"] as! NSString, type: "Device")
                    var auth = FGDeviceAuth(token: authenticate["auth_token"] as! NSString, secret: authenticate["auth_secret"] as! NSString)
                    var roomDict = (dict as! Dictionary<String, Any>)["room"] as! Dictionary<String, Any>
                    print("*** Connected to property id : \(roomDict["property_id"]!) room id : \(roomDict["room_id"]!) room number : \(roomDict["number"]!) ***" )
                    
                    //create the connection of room
                    var conn : FGConnect = FGConnect.init(nameRoom: name as NSString, roomToken: tokenRoom as NSString, rooms_id: roomDict["room_id"] as! NSNumber)
                    
                    //create the entity
                    var property : FGProperty = FGProperty(identifier: roomDict["property_id"] as! NSNumber)
                    
                    property.room?.mergeWithDictionary(dict: roomDict)
                    property.room?.auth = auth
                    property.room?.connect = conn
                    */
                    completion(connectResp)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
        self.disposebag?.insert(dispose)
        
    }
    
    //POST to disconnect to a room using guest_device auth.
    public func postDisconnectToRoom(room: FGRoom, completion: @escaping (_ roomResponse : DisconnectRoomResponse) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        //load precon for take the uid
        let preconnResp = PreconnectResponse().loadFromRealm()
        let preconn = FGPreconnect(preconnResp: preconnResp)
        
        let jsonDict : [String:Any] = ["name": room.connect!.name as String, "token": room.connect!.tokenRoom as String, "uid":preconn.uid as String, "property_id" : room.property!.identifier!, "device_type" : "guest_device", "os" : "ios"]
        var data : Data!
        var totalURL : URL!
        do{
            data = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            totalURL = try String("\(API.getBaseURL.baseURL)/v1/disconnect")?.asURL()
            //totalURL = try String("\(newUrl)/v1/disconnect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        let baseURL = totalURL as NSURL
        let timestamp = NSDate().timeIntervalSince1970
        let timestampStr:String = String(format:"%.0f", timestamp)
        var datastring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        datastring = datastring!.replacingOccurrences(of: "\n", with: "")
        datastring = datastring!.replacingOccurrences(of: " ", with: "")
        
        //using room token
        //var auth = FGAuth().loadFromRealm(type: "Device")
        let auth = FGDeviceAuth(token: room.auth!.token, secret: room.auth!.secret)
        let token = String("Token token=\"\(auth.token)\", timestamp=\"\(timestampStr)\"")
        
        //finalString to be hashed later
        let finalStr = String("\(baseURL.absoluteString!)\(timestampStr)\(datastring!)")!
        let authSign = authSignatureWithString(data: finalStr, key: auth.secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let defaultEndpoint = RxMoyaProvider.defaultEndpointMapping(target)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        let dispose = self.provider.request(.postDisconnectToRoom(room.connect!.name as String, room.connect!.tokenRoom as String, FGSession.sharedInstance.UDID as String, room.property!.identifier!, "guest_device")).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    let discResp : DisconnectRoomResponse =  DisconnectRoomResponse(dict: dict as! Dictionary<String, Any>)
                    completion(discResp)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
        self.disposebag?.insert(dispose)
        
    }
    
    
    //GET Preset to download presets.
    public func getPresetToEntity(entity: FGEntity, completion: @escaping (_ presetResponse : PresetResponse) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        //load precon for take the uid
        let preconnResp = PreconnectResponse().loadFromRealm()
        let preconn = FGPreconnect(preconnResp: preconnResp)
        
        //create the dictionary
        var entityDict : Dictionary<String, String> = [
        "room_id":entity.room?.identifier as! String,
        "property_id":entity.property?.identifier as! String,
        "brand_id":entity.brand?.identifier as! String,
        "company_id":entity.company?.identifier as! String
        ]
        
        var totalURL : URL!
        do{
            if entityDict["room_id"] != nil {
                totalURL = try String("\(API.getBaseURL.baseURL)/v1/presets?unflatten=1&uid=\(preconn.uid)")?.asURL()
            }else if entityDict["property_id"] != nil {
                totalURL = try String("\(API.getBaseURL.baseURL)/v3/companies/\(entityDict["company_id"]!)/brands/\(entityDict["brand_id"]!)/properties/\(entityDict["property_id"]!)/presets?unflatten=1")?.asURL()
            }else if entityDict["brand_id"] != nil{
                totalURL = try String("\(API.getBaseURL.baseURL)/v3/companies/\(entityDict["company_id"]!)/brands/\(entityDict["brand_id"]!)/presets?unflatten=1")?.asURL()
            }else{
                totalURL = try String("\(API.getBaseURL.baseURL)/v3/companies/\(entityDict["company_id"]!)/presets?unflatten=1")?.asURL()
            }
            
            //totalURL = try String("\(newUrl)/v1/disconnect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        let timestamp = NSDate().timeIntervalSince1970
        let timestampStr:String = String(format:"%.0f", timestamp)
        
        //for GET, the body data or payload always nil
        //var datastring = ""
        
        let auth = FGDeviceAuth(token: entity.auth!.token, secret: entity.auth!.secret)
        let token = String("Token token=\"\(auth.token)\", timestamp=\"\(timestampStr)\"")
        let baseURL = totalURL as NSURL
        
        //finalString to be hashed later
        let finalStr = String("\(baseURL.absoluteString!)\(timestampStr)")!
        let authSign = authSignatureWithString(data: finalStr, key: auth.secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let url = target.baseURL.appendingPathComponent(target.path).absoluteString.removingPercentEncoding!
            let defaultEndpoint = Endpoint<API>(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        let dispose = self.provider.request(.getPresetsOfEntity(preconn.uid as String, entityDict)).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    print(dict)
                    let presResp : PresetResponse = PresetResponse(dict: dict as! Dictionary<String, Any>)
                    completion(presResp)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
        self.disposebag?.insert(dispose)
    }
    
    //GET Room Info to download room info.
    public func getRoomInfo(room: FGRoom, completion: @escaping (_ roomResponse : RoomInfoResponse) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        var totalURL : URL!
        do{
            totalURL = try String("\(API.getBaseURL.baseURL)/v1/device/room_info")?.asURL()
            //totalURL = try String("\(newUrl)/v1/disconnect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        let timestamp = NSDate().timeIntervalSince1970
        let timestampStr:String = String(format:"%.0f", timestamp)
        
        //for GET, the body data or payload always nil
        //var datastring = ""
        
        let auth = FGDeviceAuth(token: room.auth!.token, secret: room.auth!.secret)
        let token = String("Token token=\"\(auth.token)\", timestamp=\"\(timestampStr)\"")
        let baseURL = totalURL as NSURL
        
        //finalString to be hashed later
        let finalStr = String("\(baseURL.absoluteString!)\(timestampStr)")!
        let authSign = authSignatureWithString(data: finalStr, key: auth.secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let defaultEndpoint = RxMoyaProvider.defaultEndpointMapping(target)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        let dispose = self.provider.request(.getRoomInfo).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    print(dict)
                    let roominfo : RoomInfoResponse = RoomInfoResponse(dict: dict as! Dictionary<String, Any>)
                    completion(roominfo)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
        self.disposebag?.insert(dispose)
        
    }
    
    
    //GET Guest Service Entity.
    public func getGuestService(entity: FGEntity, completion: @escaping (_ guestResponse : GuestServiceResponse) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        //load the location object from database
        /*let locationRealm = Location().loadFromRealm()
        let longitude = String(format: "%.7f", locationRealm.longitude)
        let latitude = String(format: "%.7f", locationRealm.latitude)
        let cityName = String(locationRealm.cityName)
        let countryName = String(locationRealm.countryName)
        let stateName = String(locationRealm.stateName)
        */
        //create the dictionary
        let entityDict : Dictionary<String, String> = [
            "room_id":entity.room?.identifier as! String,
            "property_id":entity.property?.identifier as! String,
            "brand_id":entity.brand?.identifier as! String,
            "company_id":entity.company?.identifier as! String
        ]
        
        let longitude = "13.7444363"
        let latitude = "100.5565567"
        let cityName = "Vadhana"
        let countryName = "Thailand"
        let stateName = "Bangkok"
        var totalURL : URL!
        do{
            totalURL = try String("\(API.getBaseURL.baseURL)/v3/companies/\(entity.company!.identifier)/brands/\(entity.brand!.identifier)/properties/\(entity.property!.identifier)/guest_services?lat=\(latitude)&lng=\(longitude)&country=\(countryName)&state_province=\(stateName)&city=\(cityName)")?.asURL()
            //totalURL = try String("\(newUrl)/v1/disconnect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        let timestamp = NSDate().timeIntervalSince1970
        let timestampStr:String = String(format:"%.0f", timestamp)
        
        //for GET, the body data or payload always nil
        //var datastring = ""
        
        let auth = FGCompanyAuth()
        //let auth = FGDeviceAuth(token: entity.auth!.token, secret: entity.auth!.secret)
        let token = String("Token token=\"\(auth.token)\", timestamp=\"\(timestampStr)\"")
        let baseURL = totalURL as NSURL
        
        //finalString to be hashed later
        let finalStr = String("\(baseURL.absoluteString!)\(timestampStr)")!
        let authSign = authSignatureWithString(data: finalStr, key: auth.secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let url = target.baseURL.appendingPathComponent(target.path).absoluteString.removingPercentEncoding!
            let defaultEndpoint = Endpoint<API>(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        let dispose = self.provider.request(.getGuestServicesOfEntity(entityDict, latitude, longitude, countryName, stateName, cityName)).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    //print(dict)
                    let guestRep : GuestServiceResponse = GuestServiceResponse(array: dict as! [Any])
                    completion(guestRep)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
        self.disposebag?.insert(dispose)
        
    }
    
    //GET/POST executeCoreRESTCall.
    public func executeCoreRESTCall(apicore: String, apifunc: String, payload : String, secret: String, token: String, completion: @escaping (_ : Any) -> Void){
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        //create the dictionary for payload
        var jsonDict : [String: Any]?
        
        if apifunc == "POST" {
            jsonDict = convertToDictionary(text: payload)
        }
        var data : Data!
        var totalURL : URL!
        
        do{
            if apifunc == "POST" {
                data = try JSONSerialization.data(withJSONObject: jsonDict!, options: .prettyPrinted)
            }
            totalURL = try String("\(apicore)")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        let timestamp = NSDate().timeIntervalSince1970
        let timestampStr:String = String(format:"%.0f", timestamp)
        
        //for GET, the body data or payload always nil
        //var datastring = ""
        var datastring : String?
        if apifunc == "POST" {
            datastring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            datastring = datastring!.replacingOccurrences(of: "\n", with: "")
            datastring = datastring!.replacingOccurrences(of: " ", with: "")
        }
        //let auth = FGCompanyAuth()
        //let auth = FGDeviceAuth(token: entity.auth!.token, secret: entity.auth!.secret)
        let token = String("Token token=\"\(token)\", timestamp=\"\(timestampStr)\"")
        let baseURL = totalURL as NSURL
        
        //finalString to be hashed later
        var finalStr : String = ""
        if apifunc == "GET" {
            finalStr = String("\(baseURL.absoluteString!)\(timestampStr)")!
        }else{
            finalStr = String("\(baseURL.absoluteString!)\(timestampStr)\(datastring!)")!
        }
        
        let authSign = authSignatureWithString(data: finalStr, key: secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let url = totalURL.absoluteString.removingPercentEncoding!
            let defaultEndpoint = Endpoint<API>(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        if apifunc == "GET" {
            
            self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
            let dispose = self.provider.request(.executeCoreRESTCallGET).subscribe { event in
                switch event {
                case let .next(response):
                    do{
                        let dict = try response.mapJSON()
                        print(dict)
                        let apiRep : APIResponseCall = APIResponseCall()
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
            
            self.disposebag?.insert(dispose)
        }else{
            
            self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
            let dispose = self.provider.request(.executeCoreRESTCallPOST(jsonDict!)).subscribe { event in
                switch event {
                case let .next(response):
                    do{
                        let dict = try response.mapJSON()
                         print(dict)
                        let apiRep : APIResponseCall = APIResponseCall()
                        let outputString: String = try response.mapString()
                        completion(outputString)
                    }catch {
                        print("Something wrong");
                    }
                case let .error(error):
                    print("Error : ",error)
                default:
                    break
                }
            }
            
            
            self.disposebag?.insert(dispose)
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    /**------------------------------------------------------------ NEW CORE -------------------------------------------------------------**/
    
    //GET the App-Token
    public func postTokenWithClientID(client_id : NSString, client_secret : NSString, completion: @escaping (_ apptoken : FGAppToken) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        self.providerNew = RxMoyaProvider<APINew>(manager: manager)
        let dispose = self.providerNew.request(.postTokenWithClientID(client_id as String, client_secret as String)).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    let apptoken = FGAppToken.init(dict as! Dictionary<String, AnyObject>)
                    completion(apptoken)
                }catch {
                    print("Something wrong");
                }
            case let .error(error):
                print("Error : ",error)
            default:
                break
            }
        }
        
        self.disposebag?.insert(dispose)
        
    }
}
