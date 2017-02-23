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
    
    /** An image URL. For home screen.
     Preset: app_home_screen_logo */
    var homeScreen_logoURL: URL!
    /** An image URL. For connect screen.
     Preset: app_checkin_screen_logo */
    var connectScreen_logoURL: URL!
    /** FGLink objects. App Right menu links.
     Presets: app_links */
    var links = [FGLink]()
    /** FGTabBarItem object. Contain FGTabbarTags with "Connected" and "Disconnected" status
     Presets: app_toolbar */
    var navigationBarPhoneIconDialNumber: String = ""
    /** FGTabBarItem object. Contain FGTabbarTags with "Connected" and "Disconnected" status
     Presets: app_toolbar */
    var tabbarItem: FGTabBarSetting!
    var reservationURL: URL!
    /** Terms of use URL
     Preset: app_terms_of_use_url */
    var termsOfUseURL: URL!
    /** Google Analytics Property ID.
     Preset: app_google_analytics_id */
    var googleAnalyticsID: String = ""
    /** Title for the home screen, usually a company or brand name. Default is nil.
     Preset: app_home_screen_title */
    var homeScreen_title: String = ""
    /** NSArray of FGMood objects
     Preset: general_moods */
    var moods = [FGMood]()
    /** URL of the background image of the image view behind news feed table. Default is nil.
     Preset: app_home_screen_bg_url */
    var homeScreen_BGURL: URL!
    /** URL of the background image for tablet in welcome screen. Default is nil.
     Preset: app_tablet_homescreen_url */
    var homeScreen_tablet_BGURL: URL!
    /** URL of the background image of promotion cells in home screen table. Default is nil.
     Preset: app_news_feed_cell_bg_url */
    var newsFeedCell_BGURL: URL!
    /** URL of the background image of message cells in home screen table. Default is nil.
     Preset: app_message_cell_bg_url */
    var messageCell_BGURL: URL!
    /** Background color of the image view behind news feed table. Default is white 0xFFFFFF.
     Preset: app_home_screen_bg_color */
    var homeScreen_BGColor: UIColor = hexStringToUIColor(hex: "#FFFFFF")
    /** Color of navigation bar background. Default is blue 0x199CDB.
     Preset: app_navigation_bar_bg_color */
    var navigationBar_BGColor: UIColor = hexStringToUIColor(hex: "#000000")
    /** Text color of promotion list items. Default is black 0x000000.
     Preset: app_news_feed_cell_text_color */
    var newsFeedCell_textColor: UIColor = hexStringToUIColor(hex: "#000000")
    /** Text color of message list items. Default is black 0x000000.
     Preset: app_message_cell_text_color */
    var messageCell_textColor: UIColor = hexStringToUIColor(hex: "#000000")
    /** Initial alarm time placeholder when no time is specified
     Preset: gcc_initial_alarm_time */
    var initialAlarmTime: FGTime!
    /** Timezone for displaying the time, **except for alarm time**. Default is [NSTimeZone systemTimeZone].
     Preset: gcc_system_time_zone */
    var timeZone: NSTimeZone!
    ///---------------------------
    /// @name SIP
    ///---------------------------
    /*
    /** SIP address. e.g. johnny@sip2siself.info
     Preset: app_sip_address */
    var sipAddress: String = ""
    /** SIP username. e.g. johnny
     Preset: app_sip_username */
    var sipUsername: String = ""
    /** SIP password
     Preset: app_sip_password */
    var sipPassword: String = ""
    /** SIP domain. e.g. sip2siself.info
     Preset: app_sip_domain */
    var sipDomain: String = ""
    /** SIP proxy server. e.g. proxy.sipthor.net
     Preset: app_sip_proxy_server */
    var sipProxyServer: String = ""
    /** SIP config
     Preset: app_sip_config */
    var sipConfig = [AnyHashable: Any]()
    /** SIP Prefix Number in SIP Manual
     Preset: app_sip_prefix_number */
    var sipPrefix: String = ""
    /** SIP hotel operator number. Default is @"0"
     Preset: app_sip_hotel_operator_number */
    var sipHotelOperatorNumber: String = ""
    /** Quick dial contacts. Array of FGSIPContact objects.
     Preset: app_sip_quickdial */
    var sipQuickDialContacts = [FGSIPContact]()
    /** FGSIPRate objects for countries phone rates
     Preset: app_sip_call_rate */
    var sipCallRates = [Any]()
    /** SIP additional call rates info
     Preset: app_sip_additional_call_rate_info */
    var sipCallRatesInfo: String = ""
    /** Text in "How does this work?" section of SIP dialer "How to" page.
     Preset: app_sip_dialer_howto */
    var sipHowTo: String = ""
    /** Text in sections below the "How does this work?" section. Array of FGSipHowToEntry objects.
     Preset: app_sip_dialer_howto_footer */
    var sipHowToFooter = [Any]()*/
    ///---------------------------
    /// @name App Features
    ///---------------------------
    /** Enables Messaging feature. Default is YES.
     If NO, hide "Messaging" right bar button item.
     Preset: app_feature_messaging */
    var isMessagingEnabled: Bool = true
    /** Enables View Folio feature. Default is YES.
     If NO, hide "View Folio" right menu buttton.
     Preset: app_feature_viewfolio */
    var isViewFolioEnabled: Bool = true
    /** Enables Express Checkout feature. Default is NO.
     If NO, hide "Express Checkout" button inside View Folio.
     Preset: app_feature_expresscheckout */
    var isExpressCheckOutEnabled: Bool = false
    /** Enables Openways feature. Default is NO.
     If NO, hide "Room Key" right menu buttton.
     Preset: app_feature_openways */
    var isOpenwaysEnabled: Bool = false
    /** Openways Settings: URL and companyID
     Preset: app_feature_openways_settings
     */
    var openwaysBaseURL: String = ""
    var openwaysCompanyID: String = ""
    var selectPropertyWaitTime: NSNumber?
    /** Location recheck distance for google service.
     Preset: app_location_recheck_distance */
    var recheckDistance: NSNumber?
    ///---------------------------
    /// @name TV
    ///---------------------------
    /** Poll interval (in seconds) when pre-connect messaging page is opened. If not specified, app will default to 15 seconds.
     Preset: app_message_poll_time */
    var messagePollTime: NSNumber?
    ///---------------------------
    /// @name Other
    ///---------------------------
    /** Maximum volume of GCC. Default is 255.
     Preset: gcc_maximum_volume */
    var gccMaximumVolume: Int = 255
    /** Temperature unit. Typically @"C" or @"F".
     Preset: general_temperature_format */
    var temperatureUnit: FGAirConTempUnit?
    ///---------------------------
    /// @name TV
    ///---------------------------
    /** **For testing only, wil be removed!**
     Specify whether the app should use hardcoded EPG information or not. */
    var isHardcodedEPGMode: Bool = false
    
    /** Creates a preset from NSDictionary
     @param dict JSON dictionary returned from the presets API. Object in `presets` key in room data.
     @param err Error output.
     @returns FGPresets object. Nil if dict is not valid.
     */
    
    convenience init(dictionary dict: [AnyHashable: Any]) {
        self.init()
        
        self.moods = FGMood.objects(withArray: dict["general_moods"] as! [AnyObject])! as! [FGMood]
        if self.moods == nil {
            self.moods = FGMood.objects(withArray: dict["moods"] as! [AnyObject])! as! [FGMood]
        }
        // temporary fallback
        self.homeScreen_title = dict["app_home_screen_title"] as! String
        //self.links = FGLink.links(withArray: dict["app_links"])
        self.googleAnalyticsID = dict["app_google_analytics_id"] as! String
        
        // Tabbar (lobby v2 only)
        //self.tabbarItem = FGTabBarItem(dict: dict["app_toolbar"] as! Dictionary <String, Any>)
        //        // Tabbar
        //        self.tabbarItem = ([dict[@"app_navigation_bar_phone_quickdial_number"] toNSString], nil);
        // image URLs, no default values here so vc should set placeholder image themselves
        self.homeScreen_logoURL = URL(string: dict["app_home_screen_logo"] as! String)
        self.homeScreen_BGURL = URL(string: dict["app_home_screen_bg_url"] as! String)
        self.homeScreen_tablet_BGURL = URL(string: dict["app_tablet_homescreen_url"] as! String)
        self.connectScreen_logoURL = URL(string: dict["app_checkin_screen_logo"] as! String)
        self.newsFeedCell_BGURL = URL(string: dict["app_news_feed_cell_bg_url"] as! String)
        self.messageCell_BGURL = URL(string: dict["app_message_cell_bg_url"] as! String)
        // URLs, *** use `` ***
        self.reservationURL = URL(string: dict["app_reservation_url"] as! String)
        self.termsOfUseURL = URL(string: dict["app_terms_of_use_url"] as! String)
        // Colors
        self.homeScreen_BGColor = hexStringToUIColor(hex: dict["app_home_screen_bg_color"] as! String)
        self.navigationBar_BGColor = hexStringToUIColor(hex: dict["app_navigation_bar_bg_color"] as! String)
        self.newsFeedCell_textColor = hexStringToUIColor(hex: dict["app_news_feed_cell_text_color"] as! String)
        self.messageCell_textColor = hexStringToUIColor(hex: dict["app_message_cell_text_color"] as! String)
        
        // Alarm
        //self.initialAlarmTime = (FGTime(timeColonString: dict["gcc_initial_alarm_time"]), nil)
        // placeholder time for alarm
        // Time zone
        self.timeZone = FGPresets.parseTimeZone(from: dict["gcc_system_time_zone"] as! String)
        // SIP config
        /*self.sipAddress = dict["app_sip_address"] as! String
        self.sipUsername = dict["app_sip_username"] as! String
        self.sipPassword = dict["app_sip_password"] as! String
        self.sipDomain = dict["app_sip_domain"] as! String
        self.sipProxyServer = dict["app_sip_proxy_server"] as! String*/
        // App Features .
        var app_feat = dict["app_feature_messaging"] as! Dictionary<String, Any>
        self.isMessagingEnabled = app_feat["ios"] as! NSNumber as Bool
        self.isViewFolioEnabled = dict["app_feature_viewfolio"] as! NSNumber as Bool
        self.isExpressCheckOutEnabled = dict["app_feature_expresscheckout"] as! NSNumber as Bool
        self.isOpenwaysEnabled = dict["app_feature_openways"] as! NSNumber as Bool
        self.selectPropertyWaitTime = dict["app_user_select_prop_wait_time"] as? NSNumber
        self.recheckDistance = dict["app_location_recheck_distance"] as? NSNumber
        // Openways
        var openwaysSettings: [AnyHashable: Any] = dict["app_feature_openways_settings"] as! Dictionary<String, Any>
        self.openwaysBaseURL = openwaysSettings["base_url"] as! String
        self.openwaysCompanyID = openwaysSettings["company_id"] as! String
        // Messaging
        self.messagePollTime = dict["app_message_poll_time"] as? NSNumber
        // Other
        self.gccMaximumVolume = Int(dict["gcc_maximum_volume"] as! NSNumber)
        self.temperatureUnit = self.tempUnit(from: dict["general_temperature_format"] as! String)
        // --- DEMO, to be removed ---
        self.isHardcodedEPGMode = dict["app_hardcoded_epg_mode"] as! NSNumber as Bool
    }
    /** Creates a preset with an empty dictionary, resulting in all values are set to default. */
    
    convenience override init() {
        self.init(dictionary: [:])
    }
    
    /** Finds a mood in receiver's moods array by tag.
     Case-insensitive. Returns nil if not found. */
    func tempUnit(from string: String) -> FGAirConTempUnit {
        if string.lowercased().isEqual("c") {
            return ._C
        }
        if string.lowercased().isEqual("f") {
            return ._F
        }
        return ._unknown
    }
    
    func safeURL(with obj: NSObject) -> URL {
        return URL(string: obj as! String)!
    }
    
    func mood(withTag tag: String) -> FGMood? {
        for m: FGMood in self.moods {
            if m.tag.lowercased().isEqual(tag.lowercased()) {
                return m
            }
        }
        //FGLogWarnWithClsAndFuncName("tag not found: %@", tag)
        return nil
    }
    // MARK: - internal
    // "e.g. '-5.5' or '7 | Asia/Bangkok', separated by '|'. The number is multiplied by 3600 to get seconds from GMT.
    // The string is optional. It is the time zone name that help provide more information, such as daylight saving time.
    // Each device should fall back to system timezone if empty or invalid string."
    
    class func parseTimeZone(from string: String) -> NSTimeZone {
        var tz: NSTimeZone?
        // try to find time zone string
        var comp: [Any] = string.components(separatedBy: " | ")
        if comp.count > 1 {
            let tzNumber: String = comp[0] as! String
            let tzString: String = comp[1] as! String
            tz = NSTimeZone(name: tzString)
            if tz == nil {
                tz = NSTimeZone(abbreviation: tzString)
            }
            // try to find time zone offset number
            if tz == nil {
                tz = NSTimeZone(forSecondsFromGMT: Int(tzNumber)! * 3600)
            }
        }
        // parse the whole string as offset number
        if tz == nil {
            tz = NSTimeZone(forSecondsFromGMT: Int(string)! * 3600)
        }
        return tz!
    }
 
 
    /*var homeScreen_logoURL : NSURL = NSURL(string: "")!
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
        
    }*/
}
