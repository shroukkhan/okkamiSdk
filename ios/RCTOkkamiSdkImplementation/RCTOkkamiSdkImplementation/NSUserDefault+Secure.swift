//
//  NSUserDefault+Secure.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/19/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import CryptoSwift
let kStoredObjectKey = "storedObject"

var secrets: String? = nil

extension UserDefaults {
    // MARK: - Getter methods
    
    func secretBool(forKey defaultName: String) -> Bool {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is NSNumber) {
            return object != nil
        }
        else {
            return false
        }
    }
    
    func secretData(forKey defaultName: String) -> Data? {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is Data) {
            return object! as? Data
        }
        else {
            return nil
        }
    }
    
    func secretDictionary(forKey defaultName: String) -> [AnyHashable: Any]? {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is [AnyHashable: Any]) {
            return object! as? [AnyHashable : Any]
        }
        else {
            return nil
        }
    }
    
    func secretFloat(forKey defaultName: String) -> Float {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is NSNumber) {
            return CFloat(object as! NSNumber)
        }
        else {
            return 0.0
        }
    }
    
    func secretInteger(forKey defaultName: String) -> Int {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is NSNumber) {
            return Int(object as! NSNumber)
        }
        else {
            return 0
        }
    }
    func secretStringArray(forKey defaultName: String) -> [Any]? {
        let objects: Any? = self.secretObject(forKey: defaultName)
        if (objects is [Any]) {
            for object in (objects as! Array<Any>) {
                if !(object is String) {
                    return nil
                }
            }
            return objects! as? [Any]
        }
        else {
            return nil
        }
    }
    
    func secretString(forKey defaultName: String) -> String? {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is String) {
            return object! as? String
        }
        else {
            return nil
        }
    }
    
    func secretDouble(forKey defaultName: String) -> Double {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is NSNumber) {
            return CDouble(object as! NSNumber)
        }
        else {
            return 0
        }
    }
    
    func secretURL(forKey defaultName: String) -> URL? {
        let object: Any? = self.secretObject(forKey: defaultName)
        if (object is URL) {
            return object as? URL
        }
        else {
            return nil
        }
    }
    
    func secretObject(forKey defaultName: String) -> Any? {
        /*
        // Check if we have a (valid) key needed to decrypt
        //assert(self.secret, "Secret may not be nil when storing an object securely")
        
        // Fetch data from user defaults
        var data: Data? = self.data(forKey: defaultName)
        // Check if we have some data to decrypt, return nil if no
        if data == nil {
            return nil
        }
        // Try to decrypt data
        defer {
        }
        do {
            
            
            // Generate key and IV
            var keyData = secrets?.sha384()
            var aesKey: Data? = keyData?.data.subdata(with: NSRange(location: 0, length: 32))
            var aesIv: Data? = keyData?.data.subdata(with: NSRange(location: 32, length: 16))
            // Decrypt data
            var result: CocoaSecurityResult? = CocoaSecurity.aesDecrypt(with: data, key: aesKey, iv: aesIv)
            // Turn data into object and return
            var unarchiver = NSKeyedUnarchiver(forReadingWithData: result?.data)
            var object: Any? = unarchiver?.decodeObject(forKey: kStoredObjectKey)
            unarchiver?.finishDecoding()
            return object!
        } catch let exception {
            // Whoops!
            print("Cannot receive object from encrypted data storage: \(exception.reason)")
            return nil
        }
        */
        return nil
    }
    
    // MARK: - Setter methods
    
    func setSecret(_ secret: String) {
         secrets = secret
    }
    
    func setSecretBool(_ value: Bool, forKey defaultName: String) {
        self.setSecretObject(Bool(value), forKey: defaultName)
    }
    
    func setSecretFloat(_ value: Float, forKey defaultName: String) {
        self.setSecretObject(Int(value), forKey: defaultName)
    }
    
    func setSecretInteger(_ value: Int, forKey defaultName: String) {
        self.setSecretObject(Int(value), forKey: defaultName)
    }
    
    func setSecretDouble(_ value: Double, forKey defaultName: String) {
        self.setSecretObject(Int(value), forKey: defaultName)
    }
    
    func setSecretURL(_ url: URL, forKey defaultName: String) {
        self.setSecretObject(url, forKey: defaultName)
    }
    func setSecretObject(_ value: Any, forKey defaultName: String) {
        // Check if we have a (valid) key needed to encrypt
        //assert(self.secret, "Secret may not be nil when storing an object securely")
        /*
        defer {
        }
        do {
            // Create data object from dictionary
            var data = Data()
            var archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(value, forKey: kStoredObjectKey)
            archiver.finishEncoding()
            // Generate key and IV
            var keyData: CocoaSecurityResult? = CocoaSecurity.sha384(self.secret)
            var aesKey: Data? = keyData?.data?.subdata(with: NSRange(location: 0, length: 32))
            var aesIv: Data? = keyData?.data?.subdata(with: NSRange(location: 32, length: 16))
            // Encrypt data
            var result: CocoaSecurityResult? = CocoaSecurity.aesEncrypt(with: data, key: aesKey, iv: aesIv)
            // Save data in user defaults
            self[defaultName] = result?.data
        } catch let exception {
            // Whoops!
            print("Cannot store object securely: \(exception.reason)")
        }*/
    }
}
