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

class FGHTTP: Object, NSURLConnectionDelegate {
    
    static let sharedInstance: FGHTTP = { newInstance() }()
    var provider: RxMoyaProvider<API>!
    var providerNew: RxMoyaProvider<APINew>!
    
    //initializer
    public class func newInstance() -> FGHTTP {
        return FGHTTP()
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
        //print("hmac return", hmac)
        return hmac
    }
    
    /**------------------------------------------------------------ OLD CORE -------------------------------------------------------------**/
    
    //POST device UID to get guest device auth token using Preconnect
    public func postPreconnectAuthWithUID(uid : NSString, completion: @escaping (_ precon : FGPreconnect) -> Void){
        
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
        
        var jsonDict : [String:String] = ["uid":uid as String]
        var data : Data!
        var totalURL : URL!
        do{
            data = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            totalURL = try String("\(API.getBaseURL.baseURL)/v1/preconnect")?.asURL()
            //totalURL = try String("\(newUrl)/v1/preconnect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        var baseURL = totalURL as! NSURL
        var timestamp = NSDate().timeIntervalSince1970
        var timestampStr:String = String(format:"%.0f", timestamp)
        var datastring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        datastring = datastring!.replacingOccurrences(of: "\n", with: "")
        datastring = datastring!.replacingOccurrences(of: " ", with: "")
        
        //using company token
        var token = String("Token token=\"32361e1a5a496e0c\", timestamp=\"\(timestampStr)\"")
        
        //finalString to be hashed later
        var finalStr = String("\(baseURL.absoluteString!)\(timestampStr)\(datastring!)")!
        var authSign = authSignatureWithString(data: finalStr, key: "92865cbcd9be8a19d0563006f8b81c73")

        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let defaultEndpoint = RxMoyaProvider.defaultEndpointMapping(target)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        self.provider.request(.postPreconnectWithUID(uid as String)).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    print(dict)
                    let preconn : FGPreconnect = FGPreconnect.init(dict as! Dictionary<String, AnyObject>)
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
        
    }
    
    
    //POST to connect to a room using guest_device auth and property_id.
    public func postConnectToRoom(name: String, tokenRoom: String, uid : String, preconnect : FGPreconnect, property_id : String, completion: @escaping (_ entity : FGProperty) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        var jsonDict : [String:String] = ["name": name as String, "token": tokenRoom as String, "uid":uid as String, "property_id" : property_id as String, "device_type" : "guest_device", "os" : "ios"]
        var data : Data!
        var totalURL : URL!
        do{
            data = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            totalURL = try String("\(API.getBaseURL.baseURL)/v1/connect")?.asURL()
            //totalURL = try String("\(newUrl)/v1/connect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        var baseURL = totalURL as! NSURL
        var timestamp = NSDate().timeIntervalSince1970
        var timestampStr:String = String(format:"%.0f", timestamp)
        var datastring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        datastring = datastring!.replacingOccurrences(of: "\n", with: "")
        datastring = datastring!.replacingOccurrences(of: " ", with: "")
        
        //using preconnect guest_device token
        var auth = FGAuth(token: preconnect.auth!.token, secret: preconnect.auth!.secret)
        var token = String("Token token=\"\(auth.token)\", timestamp=\"\(timestampStr)\"")
        
        //finalString to be hashed later
        var finalStr = String("\(baseURL.absoluteString!)\(timestampStr)\(datastring!)")!
        var authSign = authSignatureWithString(data: finalStr, key: auth.secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let defaultEndpoint = RxMoyaProvider.defaultEndpointMapping(target)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        self.provider.request(.postConnectToRoomWithEntity(name, tokenRoom, uid, property_id, "guest_device")).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()
                    print(dict)
                    
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

                    completion(property)
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
    
    //POST to disconnect to a room using guest_device auth and property_id.
    public func postDisconnectToRoom(room: FGRoom, completion: @escaping (_ room : FGRoom) -> Void){
        
        let policies: [String: ServerTrustPolicy] = [
            "api.fingi-staging.com" : .disableEvaluation,
            "api.fingi.com" : .disableEvaluation,
            "app.develop.okkami.com" : .disableEvaluation
        ]
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        /*var sessionIns = FGSession()
        sessionIns = sessionIns.loadFromRealm()
        */
        var jsonDict : [String:Any] = ["name": room.connect!.name as String, "token": room.connect!.tokenRoom as String, "uid":FGSession.sharedInstance.UDID as String, "property_id" : room.property!.identifier, "device_type" : "guest_device", "os" : "ios"]
        var data : Data!
        var totalURL : URL!
        do{
            data = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            totalURL = try String("\(API.getBaseURL.baseURL)/v1/disconnect")?.asURL()
            //totalURL = try String("\(newUrl)/v1/disconnect")?.asURL()
        }catch{
            print("Error in JSON Serialization")
        }
        
        var baseURL = totalURL as! NSURL
        var timestamp = NSDate().timeIntervalSince1970
        var timestampStr:String = String(format:"%.0f", timestamp)
        var datastring = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        datastring = datastring!.replacingOccurrences(of: "\n", with: "")
        datastring = datastring!.replacingOccurrences(of: " ", with: "")
        
        //using room token
        //var auth = FGAuth().loadFromRealm(type: "Device")
        var auth = FGDeviceAuth(token: room.auth!.token, secret: room.auth!.secret)
        var token = String("Token token=\"\(auth.token)\", timestamp=\"\(timestampStr)\"")
        
        //finalString to be hashed later
        var finalStr = String("\(baseURL.absoluteString!)\(timestampStr)\(datastring!)")!
        var authSign = authSignatureWithString(data: finalStr, key: auth.secret as String)
        
        //setting the header
        let endpointClosure = { (target: API) -> Endpoint<API> in
            let defaultEndpoint = RxMoyaProvider.defaultEndpointMapping(target)
            return defaultEndpoint.adding(httpHeaderFields: ["Accept": "application/json", "Content-Type" : "application/json", "Authorization" : token!, "X-Fingi-Signature":authSign], parameterEncoding: JSONEncoding.default)
        }
        
        //call the response
        self.provider = RxMoyaProvider<API>(endpointClosure: endpointClosure,manager: manager, plugins: [NetworkLoggerPlugin(verbose: true)])
        self.provider.request(.postDisconnectToRoom(room.connect!.name as String, room.connect!.tokenRoom as String, FGSession.sharedInstance.UDID as String, room.property!.identifier, "guest_device")).subscribe { event in
            switch event {
            case let .next(response):
                do{
                    let dict = try response.mapJSON()                    
                    var roomSelf = FGRoom()
                    completion(roomSelf)
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
        self.providerNew.request(.postTokenWithClientID(client_id as String, client_secret as String)).subscribe { event in
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
        
    }
}
