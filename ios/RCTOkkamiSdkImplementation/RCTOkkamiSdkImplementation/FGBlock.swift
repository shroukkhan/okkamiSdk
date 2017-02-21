//
//  FGBlock.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/20/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation

typealias FGArrayBlock = (_ arr: NSArray?, _ error: Error?) -> Void
typealias FGObjectBlock = (_ obj: AnyObject?, _ error : Error?) -> Void
typealias FGVoidBlock = ()->Void
typealias FGErrorBlock = (_ error : Error?) -> Void
typealias FGCommandOnlyBlock = (_ cmd : FGCommand?) -> Void
typealias FGBoolBlock = (_ success : Bool, _ error: Error?)->Void
/*typedef void (^FGVoidBlock)();
typedef void (^FGErrorBlock)(NSError *err);
typedef void (^FGDictionaryBlock)(NSDictionary *dict, NSError *err);
typedef void (^FGObjectAndChangeDictBlock)(id observedObj, NSDictionary *change);
typedef void (^FGBoolBlock)(BOOL success, NSError *err);
typedef void (^FGObjectBlock)(id obj, NSError *err);
typedef void (^FGJsonDictOrArrayBlock)(id jsonObj, NSError *err);
typedef void (^FGStringBlock)(NSString *str, NSError *err);

typedef void (^FGCommandOnlyBlock)(FGCommand *cmd);
typedef void (^FGCommandBlock)(FGCommand *cmd, NSError *err);
typedef void (^FGNodeBlock)(FGNode *node, NSError *err);
typedef void (^FGEntityBlock)(FGEntity *entity);
typedef void (^FGPropertyBlock)(FGProperty *property, NSError *err);
typedef void (^FGRoomBlock)(FGRoom *room, NSError *err);
typedef void (^FGAuthBlock)(FGAuth* auth, NSError *err);
typedef void (^FGDeviceBlock)(FGComponent *device, NSError *err);
typedef void (^FGPreferencesBlock)(FGPreferences *preference, NSError *err);
typedef void (^FGFolioBlock)(FGFolio *folio, NSError *err);
typedef void (^FGSIPLoginBlock)(FGSIPLogin *login, NSError *err);*/
