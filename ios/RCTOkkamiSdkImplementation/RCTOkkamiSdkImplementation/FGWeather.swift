//
//  FGWeather.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit


class FGWeatherTemp : NSObject {
    var celsius: NSNumber?
    var fahrenheit: NSNumber?
    
    init(dictionary dict: [AnyHashable: Any]) {
        super.init()
        self.celsius = dict["celsius"] as? NSNumber
        self.fahrenheit = dict["fahrenheit"] as? NSNumber
        
    }
}
class FGWeatherTempRange : NSObject {
    
    var high: FGWeatherTemp?
    var low: FGWeatherTemp?
    
    init(dictionary dict: [AnyHashable: Any]) {
        
        super.init()
        var tempErr: Error?
        let high = FGWeatherTemp(dictionary: dict["high"] as! [AnyHashable : Any])
        
        if tempErr == nil {
            self.high = high
        }
        
        let low = FGWeatherTemp(dictionary: dict["low"] as! [AnyHashable : Any])
        if tempErr == nil {
            self.low = low
        }
        
    }
}

class FGWeatherForecast : NSObject {
    var condition: String = ""
    var iconURL: URL?
    var date: FGWeatherDate?
    var tempRange: FGWeatherTempRange?
    
    init(dictionary dict: [AnyHashable: Any]) {
        /*if !(dict is [AnyHashable: Any]) {
         err = Error.fingiError(withCode: FG_ErrorCode_InvalidResponse, description: "Cannot parse weather date, input is not a dictionary.", recovery: FG_ErrorMsgForDummies_TechnicalIssueTryAgain)
         return nil
         }*/
        super.init()
        self.date = FGWeatherDate(dictionary: dict["date"] as! [AnyHashable : Any])
        self.iconURL = URL(string: dict["icon"] as! String)
        self.condition = dict["condition"] as! String
        self.tempRange = FGWeatherTempRange(dictionary: dict["temp"] as! [AnyHashable : Any])
        
    }
}

class FGWeatherDate : NSObject {
    var weekday: String = ""
    var day: NSNumber?
    var month: NSNumber?
    var year: NSNumber?
    
    init(dictionary dict: [AnyHashable: Any]) {
        
        super.init()
        
        self.weekday = dict["weekday"] as! String
        self.day = dict["day"] as? NSNumber
        self.month = dict["month"]  as? NSNumber
        self.year = dict["year"] as? NSNumber
        
    }
}

class FGWeather : NSObject {
    var location: String = ""
    var currentCondition: String = ""
    var currentIconURL: URL?
    var currentTemp: FGWeatherTemp?
    /** FGWeatherForecast objects */
    var forecasts = [Any]()
    
    init(dictionary dict: [AnyHashable: Any]) {
        
        super.init()
        
        self.location = dict["location"] as! String
        var dict_current: [AnyHashable: Any] = dict["current"] as! [AnyHashable : Any]
        self.currentCondition = dict_current["condition"] as! String
        self.currentIconURL = URL(string: dict_current["icon"] as! String)
        self.currentTemp = FGWeatherTemp(dictionary: dict_current["temp"] as! [AnyHashable : Any])
        var m = [Any]()
        let arr_forecast: [Any] = dict["forecast"] as! [Any]
        for d_forecast in arr_forecast {
            let wf = FGWeatherForecast(dictionary: d_forecast as! [AnyHashable : Any])
            /*if wf != nil {
                
            }*/
            m.append(wf)
        }
        self.forecasts = [Any](arrayLiteral: m)
        
    }
}
