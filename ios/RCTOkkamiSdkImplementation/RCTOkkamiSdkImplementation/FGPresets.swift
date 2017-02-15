//
//  Presets.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/4/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


class FGPresets: NSObject {
    
    var homeScreen_logoURL : NSURL = NSURL(string: "")!
    var connectScreen_logoURL : NSURL = NSURL(string: "")!
    var links : NSArray = []
    var navigationBarPhoneIconDialNumber : NSString = ""
    var reservationURL : NSURL = NSURL(string: "")!
    var termsOfUseURL : NSURL = NSURL(string: "")!
    var googleAnalyticsID : NSString = ""
    var homeScreen_title : NSString = ""
    var moods : NSArray = []
    var homeScreen_BGURL : NSURL = NSURL(string: "")!
    var homeScreen_tablet_BGURL : NSURL = NSURL(string: "")!
    var newsFeedCell_BGURL : NSURL = NSURL(string: "")!
    var messageCell_BGURL : NSURL = NSURL(string: "")!
    var homeScreen_BGColor : UIColor = UIColor.black
    var navigationBar_BGColor : UIColor = UIColor.black
    var newsFeedCell_textColor : UIColor = UIColor.black
    var messageCell_textColor : UIColor = UIColor.black
    var timeZone : NSTimeZone = NSTimeZone.init(abbreviation: "GMT")!

    
    
    convenience init(_ dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
    }
}
