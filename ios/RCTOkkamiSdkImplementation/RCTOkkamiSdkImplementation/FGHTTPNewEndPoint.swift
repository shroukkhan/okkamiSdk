//
//  FGHTTPNewEndPoint.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/6/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Moya


private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

let APINewProvider = MoyaProvider<APINew>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

//dynamic base new end point
var urlBaseNewEndPoint : URL = URL(string: "https://app.develop.okkami.com")!

public func setNewBaseURL(baseUrl: String){
    urlBaseNewEndPoint = URL(string: baseUrl)!
}
public func getNewBaseURL()->URL{
    return urlBaseNewEndPoint
}

public enum APINew {
    case postTokenWithClientID(String, String)
    case postTokenWithClientIDForUserToken(String, String, String, String)
    case postTokenForCreateUser(String,String,String,String,String,String,String,String,String,String,String,String)
    case getUserProfile(String)
}

extension APINew: TargetType {
    public var baseURL: URL { return URL(string: "https://app.develop.okkami.com")! }
    public var path: String {
        switch self {
        case .postTokenWithClientID(_,_):
            return "/oauth/token"
        case .postTokenWithClientIDForUserToken(_,_,_,_):
            return "/oauth/token"
        case .postTokenForCreateUser(_,_,_,_,_,_,_,_,_,_,_,_):
            return "/v4/users"
        case .getUserProfile(_):
            return "v4/users/profile"
        }
        
    }
    public var method: Moya.Method {
        switch self {
        case .postTokenWithClientID, .postTokenForCreateUser, .postTokenWithClientIDForUserToken:
            return .post
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .postTokenWithClientID(let client_id, let client_secret):
            return ["client_id":client_id, "client_secret":client_secret, "grant_type":"client_credentials"]
        case .postTokenWithClientIDForUserToken(let client_id, let client_secret, let email, let password):
            return ["client_id":client_id, "client_secret":client_secret, "email":email,"grant_type":"password", "password":password]
        case .postTokenForCreateUser(let access_token, let first_name, let last_name, let email, let password, let password_confirmation, let phone, let avatar, let country, let state, let city, let languange):
            return ["access_token":access_token, "user[first_name]":first_name, "user[last_name]":last_name,"user[email]":email, "user[password]":password,"user[password_confirmation]":password_confirmation,"user[phone]":phone,"user[avatar]":avatar,"user[country]":country,"user[state]":state,"user[city]":city,"user[languange]":languange]
        case .getUserProfile(let access_token):
            return ["access_token":access_token]
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var task: Task {
        return .request
    }
    
    public var validate: Bool {
        return false
    }
    
    public var sampleData: Data {
        switch self {
        case .postTokenWithClientID:
            return "Post Token".data(using: String.Encoding.utf8)!
        default:
            return "Sample Data".data(using: String.Encoding.utf8)!
        }
    }
}
