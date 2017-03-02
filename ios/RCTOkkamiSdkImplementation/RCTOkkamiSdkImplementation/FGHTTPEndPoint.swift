//
//  HTTPEndPoint.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/3/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Moya
import Alamofire

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

let APIProvider = MoyaProvider<API>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}


public enum API {
    case postPreconnectWithUID(String)
    case postAPNSToken(String, String)
    case postConnectToRoomWithEntity(String, String, String, String, String)
    case postDisconnectToRoom(String, String, String, NSString, String)
    case postUsingAuth(String, String, String)
    case postPreset(Dictionary<String, String>)
    case postMarkMessageAsRead(String, String)
    case getRoomInfo
    case getDeviceRoomsWithCallback(String)
    case getPresetsOfEntity(String, Dictionary<String, Any>)
    case getGuestServicesOfEntity(Dictionary<String, Any>, String, String, String, String, String)
    case getParanetGuestOfDeviceWithAuth
    case getFolioOfRoom
    case getPromotionsOfEntity
    case getPropertyEntityLinesWithLocation(String, String, String)
    case getUsingAuth
    case getPropertiesPromotions(String)
    case getPropertiesTVChannel(String)
    case getAllRooms(String)
    case getConversation(String, String)
    case deleteConversation(String, String)
    case getBaseURL
    case executeCoreRESTCallPOST(Dictionary<String, Any>)
    case executeCoreRESTCallGET
}

struct JsonArrayEncoding: Moya.ParameterEncoding {
    
    public static var `default`: JsonArrayEncoding { return JsonArrayEncoding() }
    
     public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var req = try urlRequest.asURLRequest()
        let json = try JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = json
        return req
    }
    
}

//dynamic base old end point
var urlBaseEndPoint : URL = URL(string: "https://api.fingi-staging.com")!

public func setOldBaseURL(baseUrl: String){
    urlBaseEndPoint = URL(string: baseUrl)!
}
public func getOldBaseURL()->URL{
    return urlBaseEndPoint
}

extension API: TargetType {
    public var baseURL: URL { return URL(string: "https://api.fingi-staging.com")! }
    public var path: String {
        switch self {
        case .postPreconnectWithUID(_):
            return "/v1/preconnect"
        case .postAPNSToken(_,_):
            return "/v1/device/push_info"
        case .postConnectToRoomWithEntity(_,_,_,_,_):
            return "/v1/connect"
        case .postDisconnectToRoom(_,_,_,_,_):
            return "/v1/disconnect"
        case .postUsingAuth(_,_,_):
            return "/v3/guest/sign_in"
        case .postPreset(_):
            return "/v1/presets"
        case .postMarkMessageAsRead(let properties,_):
            return "/v2/properties/\(properties.urlEscaped)/messaging/mark_as"
        case .getRoomInfo:
            return "/v1/device/room_info"
        case .getDeviceRoomsWithCallback(let udid):
            return "/v1/devices/\(udid.urlEscaped)/rooms"
        case .getPresetsOfEntity(let udid, let item):
            if item["room_id"] != nil {
                return "/v1/presets?unflatten=1&uid=\(udid.urlEscaped)"
            }else{
                if item["property_id"] != nil {
                    return "/v3/companies/\(item["company_id"]!)/brands/\(item["brand_id"]!)/properties/\(item["property_id"]!)/presets?unflatten=1"
                }else if item["brand_id"] != nil{
                    return "/v3/companies/\(item["company_id"]!)/brands/\(item["brand_id"]!)/presets?unflatten=1"
                }else{
                    return "/v3/companies/\(item["company_id"]!)/presets?unflatten=1"
                }
            }
        case .getGuestServicesOfEntity(let item, let lang, let long, let country, let state_province, let city):
            return "/v3/companies/\(item["company_id"]!)/brands/\(item["brand_id"]!)/properties/\(item["property_id"]!)/guest_services?lat=\(lang.urlEscaped)&lng=\(long.urlEscaped)&country=\(country.urlEscaped)&state_province=\(state_province.urlEscaped)&city=\(city.urlEscaped)"
        case .getParanetGuestOfDeviceWithAuth:
            return "/v3/guest/credentials"
        case .getFolioOfRoom:
            return "/v3/folio"
        case .getPromotionsOfEntity:
            return "/v3/promotions"
        case .getPropertyEntityLinesWithLocation(let lang, let long, let entityParam):
            return "/v3/location_services?lat=\(lang.urlEscaped)&lng=\(long.urlEscaped)\(entityParam.urlEscaped)"
        case .getUsingAuth:
            return "/v3/guest/credentials"
        case .getPropertiesPromotions(let properties):
            return "/v1/properties/\(properties.urlEscaped)/promotions"
        case .getPropertiesTVChannel(let properties):
            return "/v1/properties/\(properties.urlEscaped)/tv_channels"
        case .getAllRooms(let uid):
            return "/v1/devices/\(uid.urlEscaped)/rooms"
        case .getConversation(let version, let properties):
            return "/\(version.urlEscaped)/properties/\(properties.urlEscaped)/messaging"
        case .deleteConversation(let properties, let message_id):
            return "/v2/properties/\(properties.urlEscaped)/messaging/\(message_id.urlEscaped)"
        case .getBaseURL:
            return baseURL as! String
        case .executeCoreRESTCallPOST(let dict):
            return ""
        case .executeCoreRESTCallGET:
            return ""
        }
        
    }
    public var method: Moya.Method {
        switch self {
        case .postPreconnectWithUID, .postAPNSToken, .postConnectToRoomWithEntity, .postDisconnectToRoom, .postUsingAuth, .executeCoreRESTCallPOST:
            return .post
        case .deleteConversation:
            return .delete
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .postPreconnectWithUID(let uid):
            return ["uid":uid]
        case .postAPNSToken(let uid, let push_token):
            return ["uid": uid,"push_token" : push_token, "os" : "ios"]
        case .postConnectToRoomWithEntity(let name, let token, let uid, let property_id, let device_type):
            return ["name": name, "token": token, "uid": uid, "property_id" : property_id, "device_type" : device_type, "os":"ios"]
        case .postDisconnectToRoom(let name, let token, let uid, let property_id, let device_type):
            return ["name": name, "token": token, "uid": uid, "property_id" : property_id, "device_type" : device_type, "os":"ios"]
        case .postUsingAuth(let guest, let email, let password):
            return ["guest" : guest, "email":email, "password":password]
        case .postMarkMessageAsRead(let properties, let message_id):
            return ["message_id":message_id,"mark":"read"]
        case .executeCoreRESTCallPOST(let item):
            return item
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
        //return JsonArrayEncoding.default
        //return JSONEncoding.default
    }
    
    public var task: Task {
        return .request
    }
    
    public var validate: Bool {
        return false
    }
    
    public var sampleData: Data {
        switch self {
        case .postConnectToRoomWithEntity:
            return "Connect To Room".data(using: String.Encoding.utf8)!
        default:
            return "Sample Data".data(using: String.Encoding.utf8)!
        }
    }
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
    /**Dynamic route for API End Point
    if TargetType.self == API.self {
        return urlBaseEndPoint.appendingPathComponent(route.path).absoluteString
    }else if TargetType.self == APINew.self{
        return urlBaseNewEndPoint.appendingPathComponent(route.path).absoluteString
    }**/
}
