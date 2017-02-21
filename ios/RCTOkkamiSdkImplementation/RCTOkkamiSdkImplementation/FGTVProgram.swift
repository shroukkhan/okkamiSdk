//
//  FGTVProgram.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation

class FGTVProgram: NSObject {
    /** Program's channel number assigned by property */
    var chNo: String = ""
    /** The raw program ID from provider */
    var epgID: String = ""
    /** Program name */
    var name: String = ""
    /** Program start time */
    var timeStart: Date!
    /** Program end time, may be nil. */
    var timeEnd: Date!
    /** Initializes a program. */
    static var dateFormatterHHmm: DateFormatter!{
        get{
            if self.dateFormatterHHmm == nil {
                self.dateFormatterHHmm = DateFormatter()
                //[_dateFormatterHHmm setTimeZone:[FGSession shared].currentPresets.timeZone];
                self.dateFormatterHHmm.dateFormat = "HH:mm"
            }
            return self.dateFormatterHHmm
        }set{
            self.dateFormatterHHmm = newValue
        }
    }
    
    init(dictionary dict: [AnyHashable: Any]) {
        super.init()
        
        
        self.chNo = String(object: dict["ch_no"]!)!
        let x = (self.chNo as NSString).boolValue
        if !x {
            self.chNo = String(object: dict["ch_id"]!)!
        }
        // temporary backward compatibility
        self.epgID = String(object: dict["epg_id"] as Any)!
        self.name = String(object: dict["name"] as Any)!
        
        self.timeStart = Date.fromRFC3339String(string: dict["start_time"] as! String)
        self.timeEnd = Date.fromRFC3339String(string: dict["end_time"] as! String)
        
    }
    override var description: String{
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        var timeString: String = ""
        let startTimeString: String = f.string(from: self.timeStart)
        let endTimeString: String = f.string(from: self.timeEnd)
        if (startTimeString != "") && (endTimeString != ""){
            timeString = "  \(startTimeString)-\(endTimeString)"
        }
        else if startTimeString != "" {
            timeString = startTimeString
        }
        
        return "[<\(self)> time:\(timeString) name:\(self.name)]"
    }
    
    func epg(fromArray array: [Any], error err: Error?) -> [Any] {
        let _array = array
        var m = [Any]()
        //_array = _array.filteredArrayForKind(of: NSDictionary.self)
        for d in _array {
            let epg: FGTVProgram? = d as! FGTVProgram
            if epg != nil {
                m.append(epg!)
            }
        }
        return [Any](arrayLiteral: m)
    }
}
