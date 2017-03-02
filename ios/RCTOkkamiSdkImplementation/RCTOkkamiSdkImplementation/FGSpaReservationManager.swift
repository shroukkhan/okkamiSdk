//
//  FGSpaReservationManager.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation

class FGSpaReservationManager: NSObject {
    var selectedTreatment: FGSpaTreatment!
    
    /*func getAvailableSpaTreatments(forLocation locationId: NSNumber, category categoryId: NSNumber, subcategory subcategoryId: NSNumber, callback block: @escaping FGArrayBlock) -> NSURLConnection {
        return FGAdapterRequest.shared().getAvailableSpaTreatments(to: FGSession.shared().selectedEntity.room, location: locationId, category: categoryId, subcategory: subcategoryId, callback: {(_ arr: [Any], _ err: Error) -> Void in
            print(arr)
        })
    }
    
    func getAvailableSpaTimeslots(for treatment: FGSpaTreatment, date: Date, gender genderId: NSNumber, callback block: @escaping FGObjectBlock) -> NSURLConnection {
        var components: DateComponents? = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components?.hour = 0
        components?.minute = 0
        components?.second = 0
        var startDate: Date? = Calendar.current.date(from: components!)
        //end date is one day in the future
        var dayComponent = DateComponents()
        dayComponent.day = 1
        dayComponent.second = -1
        var endDate: Date? = Calendar.current.date(byAdding: dayComponent, to: startDate!)
        return FGAdapterRequest.shared().getAvailableSpaTimeslots(to: FGSession.shared().selectedEntity.room, treatment: treatment, start: startDate, end: endDate, gender: genderId, callback: {(_ arr: [Any], _ err: Error) -> Void in
            if !err {
                treatment.update(withTimeslotsArray: arr)
            }
            print(block)
            //BLOCK_SAFE_RUN(block, treatment, err)
        })
    }
    
    func makeReservation(for treatment: FGSpaTreatment, date: Date, callback block: @escaping FGObjectBlock) -> NSURLConnection {
        return FGAdapterRequest.shared().makeSpaAppointment(to: FGSession.shared().selectedEntity.room, treatment: treatment, date: date, callback: {(_ obj: Any, _ err: Error) -> Void in
            print(block)
            //BLOCK_SAFE_RUN(block, obj, err)
        })
    }*/
}
