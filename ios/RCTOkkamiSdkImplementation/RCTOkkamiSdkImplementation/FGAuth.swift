//
//  FGAuth.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/4/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Realm
import RealmSwift


class FGPreconnectAuth : FGAuth{
    
    override init(token: NSString, secret: NSString) {
        super.init(token: token, secret: secret)
    }
    
    private func authType() -> NSString{
        return "Preconnect Auth"
    }
}
class FGDeviceAuth : FGAuth{
    
    override init(token: NSString, secret: NSString) {
        super.init(token: token, secret: secret)
    }
    
    private func authType() -> NSString{
        return "Device Auth"
    }
}

class FGCompanyAuth : FGAuth{
    
    init() {
        super.init(token: "32361e1a5a496e0c", secret: "92865cbcd9be8a19d0563006f8b81c73")
    }
    
    private func authType() -> NSString{
        return "Company Auth"
    }
}

class FGAuth: NSObject {
    
    var token : NSString = ""
    var secret : NSString = ""
    
    init(token: NSString, secret : NSString) {
        super.init()
        self.token = token
        self.secret = secret
    }
    
    
}




