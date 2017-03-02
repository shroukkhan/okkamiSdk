//
//  FGSpaTreatment.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation

class FGSpaTreatment: NSObject {
    var treatmentId: NSNumber!
    var locationId: NSNumber!
    var name: String = ""
    var explanation: String = ""
    var price: NSNumber!
    var currencyCode: String = ""
    /** Array of Dates */
    var timeslots = [Date]()
    
    
    init(dictionary dict: [AnyHashable: Any]) {
        super.init()
        
        self.treatmentId = dict["id"] as! NSNumber
        self.locationId = dict["location_id"] as! NSNumber
        self.name = dict["name"] as! String
        self.explanation = dict["description"] as! String
        let price = dict["price"] as! Dictionary<String,Any>
        self.price = price["amount"] as! NSNumber
        self.currencyCode = price["currency_code"] as! String
        self.timeslots = []
    }
    
    func update(withTimeslotsArray rawTimeslots: [Any]) {
        let dateFormatter = DateFormatter()
        var slots = [Date]()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        for rawTimeSlot in rawTimeslots {
            let dateString: String = (rawTimeSlot as! Dictionary<String,Any>)["start_date_time"] as! String
            let date: Date? = dateFormatter.date(from: dateString)
            if date != nil {
                slots.append(date!)
            }
        }
        self.timeslots = slots
    }
    
    override var description: String {
        return "Spa Treatment \(self.treatmentId): \(self.name) - \(self.explanation)"
    }
}
