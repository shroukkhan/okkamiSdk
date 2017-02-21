//
//  FGDeviceSubclasses.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

extension FGDevice {
    
    class func allSubclasses() -> [AnyClass] {
        var result: [AnyClass]? = nil
        /* TODO: move below code to the static variable initializer (dispatch_once is deprecated) */
        ({() -> Void in
            // *** List all FGComponentBase subclasses here. Yeah, I know... ***
            result = [FGDeviceGCC.self, FGDeviceFRCD.self, FGDeviceGuest.self, FGDeviceFGCTV.self, FGDeviceVirtualFRCD.self]
        })()
        return result!
    }
}

class FGDeviceGCC: FGDevice{
    
    var isActive: Bool = false
    
    // This is private to make the class cleaner in use.
    private var storedDate : NSDate?
    
    var dateTime: NSDate? {
        get{
            if self.dateTime == nil {
                //self.dateTime = self.room.presets.initialAlarmTime.nearestFutureDate(withTimeZone: FGDeviceGCC.timeZone)
            }
            return storedDate
        }set{
            storedDate = newValue
        }
    }
    
    var dateTime_prev: Date!
    var isActive_prev: NSNumber!
    var alarmStateDeliverTimer: Timer!
    
    
    override var type: NSString?{
        get{
            return self.type
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }

    
    class func timeZone() -> NSTimeZone {
        return NSTimeZone(abbreviation: "UTC")!
    }
    
    class func alarmHourMinuteFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .short
        f.timeZone = FGDeviceGCC.timeZone() as TimeZone!
        return f
    }
    
    
}

class FGDeviceGuest: FGDevice{
    override var type: NSString?{
        get{
            return "guest_device"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }

}

class FGDeviceFRCD: FGDevice{
    override var type: NSString?{
        get{
            return "frcd"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
}

class FGDeviceFGCTV: FGDevice{
    override var type: NSString?{
        get{
            return "fgc_tv"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
}

class FGDeviceVirtualFRCD: FGDevice{
    override var type: NSString?{
        get{
            return "virtual_frcd"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
}


class FGDeviceSubclasses: NSObject {
    
    
}
