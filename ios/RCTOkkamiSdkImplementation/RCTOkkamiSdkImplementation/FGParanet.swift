//
//  FGParanet.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/4/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation


class FGParanetCRM: NSObject {
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String?{
        get{
            if passwordWasSet {
                return UserDefaults.standard.secretString(forKey: FGParanetCRM.kSavedParanetPasswordKey)
            }
            else {
                return nil
            }
        }set{
            passwordWasSet = true
            UserDefaults.standard.setSecretObject(password!, forKey: FGParanetCRM.kSavedParanetPasswordKey)
            UserDefaults.standard.synchronize()
        }
    }
    var phoneNumber: String = ""
    var isSignedIntoCRM: Bool = false
    var isCanAutoconnect: Bool = false
    var fingiGuestNumber: NSNumber!
    var preferences = [AnyHashable: Any]()
    
    var passwordWasSet: Bool = false
    
    
    init(createOrSignInResponse response: [AnyHashable: Any]) {
        super.init()
        
        self.parseSign(inResponse: response)
        
    }
    init?(crmCredentialsResponse response: [AnyHashable: Any]) {
        super.init()
        
        let responseEmail: Any? = response["email"]
        let responsePassword: Any? = response["password"]
        if (responseEmail as AnyObject).isEqual(NSNull()) || !(responseEmail != nil) || (responsePassword as AnyObject).isEqual(NSNull()) || !(responsePassword != nil) {
            //FGLogInfoWithClsAndFuncName("Credentials API has no account saved for this device.")
        }
        self.email = response["email"] as! String
        let password: String = response["password"] as! String
        self.password = password
        
    }
    
    func signIn(withCallback block: @escaping (_ paranet: FGParanetCRM, _ err: Error) -> Void) {
        /*if !self.email.length || !self.password?.length {
            BLOCK_SAFE_RUN(block, nil, Error(domain: FingiSDKErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Paranet email and password are missing."]))
            return
        }
        var path: String = "v3"
        path = URL(fileURLWithPath: path).appendingPathComponent(FGSession.shared().selectedEntity.downToPropertyLevel.pathComponentWithParents).absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("guest/sign_in").absoluteString
        FGHTTP.shared().post(using: FGSession.shared().preconnect.auth, relativePath: path, json: ["guest": ["email": self.email, "password": self.password]], callback: {(_ jsonObj: Any, _ err: Error) -> Void in
            if !err {
                self.parseSign(inResponse: jsonObj)
                BLOCK_SAFE_RUN(block, self, nil)
            }
            else {
                BLOCK_SAFE_RUN(block, nil, err)
            }
        })*/
    }
    func parseSign(inResponse response: [AnyHashable: Any]) {
        self.firstName = response["first_name"] as! String
        self.lastName = response["last_name"] as! String
        self.email = response["email"] as! String
        self.phoneNumber = response["phone"] as! String
        self.fingiGuestNumber = response["id"] as! NSNumber
        self.isSignedIntoCRM = response["crm_signed_in"] as! Bool
        self.isCanAutoconnect = ((response["checked_in"] as! Bool) || (response["pre_checked_in"] as! Bool))
        //Make sure preferences are nil, so that they get reloaded the first time a user navigates to a preference node
        self.preferences = [:]
    }
    
    func requestPreferencesIfNeeded(withCallback block: @escaping (_ preferences: [AnyHashable: Any], _ err: Error) -> Void) {
        /*if self.preferences {
            BLOCK_SAFE_RUN(block, self.preferences, nil)
            return
        }
        var path: String = "v3"
        path = URL(fileURLWithPath: path).appendingPathComponent(FGSession.shared().selectedEntity.downToPropertyLevel.pathComponentWithParents).absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("guest/preferences").absoluteString
        FGHTTP.shared().getUsing(FGSession.shared().preconnect.auth, relativePath: path, callback: {(_ jsonObj: Any, _ err: Error) -> Void in
            if err {
                self.preferences = [:]
            }
            else {
                self.preferences = try? FGNodeSelectionBuilder.selections(fromParanetPrefsDict: jsonObj)
            }
            BLOCK_SAFE_RUN(block, self.preferences, err)
        })*/
    }
    func preferenceValues() -> [AnyHashable: Any] {
        let dict = [AnyHashable: Any]()
        for key in self.preferences.keys {
            //dict[key] = self.preferences[key].paranetValue()
        }
        return dict
    }
    static let kSavedParanetPasswordKey: String = "2m9#zdfl;a7un!27v1"
    
    override var description: String {
        return "Paranet Guest: \(self.firstName) \(self.lastName) - \(self.email)\nPreferences: \(self.preferenceValues())"
    }
}
