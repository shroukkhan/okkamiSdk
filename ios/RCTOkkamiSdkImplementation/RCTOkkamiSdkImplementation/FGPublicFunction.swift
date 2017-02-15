//
//  FGRealmConfig.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/5/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation
import Moya
import Moya_ModelMapper
import UIKit
import RxCocoa
import RxSwift
import Mapper
import RealmSwift
import Realm

@objc public class FGPublicFunction: NSObject {
    
    
    public class func newInstance() -> FGPublicFunction {
        return FGPublicFunction()
    }
    
    public func migration(){
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        
        config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    public func setupRealm(){
        var config = Realm.Configuration()
        
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("rctokkamisdk.realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    
}


