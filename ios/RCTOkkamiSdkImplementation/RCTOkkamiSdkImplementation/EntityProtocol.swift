//
//  EntityProtocol.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation

protocol EntityProtocol {

    /** Entity name and id **/
    var identifier : NSNumber { get set }
    var name : NSString { get set }
    
    /** Room auth. **/
    var auth : FGAuth? { get set }
    
    /** Room login/connect credentials. **/
    var connect : FGConnect? { get set }
    
    var room : FGRoom? { get set }
    var property : FGProperty? { get set }
    var brand : FGBrand? { get set }
    var company : FGCompany? { get set}
    
    /** Initializes with a dictionary that has `id` and `name` fields. */
    init(dictionary: Dictionary<String, AnyObject>)
    init(identifier: NSNumber)
    
    /** Initializes with `id`. */
    //init(_ identifier: NSInteger, way : NSString)
    
    //func classFromEntityType(type : NSString) -> AnyClass
    /*func room() -> FGRoom
    func property() -> FGProperty
    func brand() -> FGProperty
    func company() -> FGCompany
    */
    
    func connectWithObject()
    
    /** Presets data manager.Its object will be a FGPresets object.
     A preset object with default values is assigned when receiver is initialized, so it will never be nil. */
    //@property (strong, nonatomic) FGDataManager *presetsDM;
    /** Promotions data manager. Its object will be an array of FGPromotionNode objects. */
    //@property (strong, nonatomic) FGDataManager *promotionsDM;
    /** Guest services data manager. Its object will be an array of FGNode subclass objects.
     Data is cached and used when no internet connection. */
    //@property (strong, nonatomic) FGDataManager *guestServicesDM;
    /** Returns the object of `presetsDM`. */
    //@property (strong, readonly, nonatomic) FGPresets *presets;
    /** Auth token and secret, same as -auth. If nil, it will search through parents. */
    //@property (strong, readonly, nonatomic) FGAuth *collapsedAuth;
    /** Room login/connect credentials. It is available after -connectWithObject: is called,
     and set to nil if state changes to any of disconnected state. */
    //@property (nonatomic, copy) FGConnect *connect;
}

