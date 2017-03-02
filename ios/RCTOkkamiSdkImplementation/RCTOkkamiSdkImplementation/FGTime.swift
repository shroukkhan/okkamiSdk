//
//  FGTime.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation

class FGTime: NSObject {
    /** Hour [0,23] */
    var hour: Int?{
        get{
            return self.hour
        }set{
            self.hour = max(0, min(newValue!, 23))
        }
    }
    /** Minute [0,59] */
    var minute: Int?{
        get{
            return self.minute
        }set{
            self.minute = max(0, min(newValue!, 59))
        }
    }
    /** Initialize new object from a string. In 24h format.
     @param string A time string with colon. e.g. @"23:20" */

    init(timeColonString string: String) {
        super.init()
        var comps = string.components(separatedBy: ":")
        if comps.count == 2 {
            self.hour = Int(comps[0])!
            self.minute = Int(comps[1])!
        }
        else {
            self.hour = 0
            self.minute = 0
        }
    }
    
    
    func nearestFutureDate(with timeZone: NSTimeZone) -> Date {
        let f = DateFormatter()
        f.timeZone = timeZone as TimeZone!
        f.dateFormat = "HH:mm"
        return (f.date(from: "\(self.hour):\(self.minute)")?.nearestFutureWithSameTimeOfDay())!
    }
}
