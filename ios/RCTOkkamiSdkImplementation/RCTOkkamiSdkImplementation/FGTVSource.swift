//
//  FGTVSource.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

import Foundation

let FGTVRemoteName_tv: String = "tv"

let FGTVRemoteName_fgc_tv: String = "fgc_tv"

let FGTVRemoteName_ip_tv: String = "ip_tv"

let FGTVRemoteName_apple_tv: String = "apple_tv"

let FGTVRemoteName_dvd: String = "dvd"

let FGTVRemoteName_freedom_ent: String = "freedom_ent"

let FGTVRemoteName_innvue: String = "innvue"

class FGTVSource: FGIconDictObject {
    /** Title of source for display */
    var title: String = ""
    /** Subtitle below the title for display (optional) */
    var subtitle: String = ""
    /** Source name used in "INPUT tv-1 <source>" command. It's used as a fallback to determine iconType. */
    var source: String = ""
    /** The type of remote to be displayed when the source is selected. */
    var remoteName: String = ""
    
    func object(withDictionary dict: [AnyHashable: Any]) -> FGTVSource {
        let obj = FGTVSource()
        obj.title = dict["title"] as! String
        obj.subtitle = dict["subtitle"] as! String
        obj.source = dict["source"] as! String
        obj.iconName = dict["icon"] as! String
        obj.remoteName = dict["remote"] as! String
        return obj
    }
    // MARK: - FGIconDictObject
    static var iconDictBuiltIn: [AnyHashable: Any]?{
        get{
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if self.iconDictBuiltIn == nil {
                    
                    self.iconDictBuiltIn = ["tv": UIImage(named: "tv_source_icon_tv")!, "hdmi": UIImage(named:"tv_source_icon_hdmi")!, "streaming": UIImage(named:"tv_source_icon_streaming")!, "internet": UIImage(named:"tv_source_icon_internet")!, "apple_tv": UIImage(named:"tv_source_icon_apple_tv")!, "vga": UIImage(named:"tv_source_icon_vga")!, "av": UIImage(named:"tv_source_icon_av")!, "component": UIImage(named:"tv_source_icon_component")!, "coaxial": UIImage(named:"tv_source_icon_coaxial")!]
                }
            }
            return self.iconDictBuiltIn
        }set{
            self.iconDictBuiltIn = newValue
        }
    }
    
    // MARK: -
    override var description: String{
        return "[<\(self)> source:\(self.source) title:\(self.title) subtitle:\(self.subtitle) remote:\(self.remoteName) icon:\(self.iconName)]"
    }
}
