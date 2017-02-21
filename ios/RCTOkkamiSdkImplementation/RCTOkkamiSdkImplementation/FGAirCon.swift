//
//  FGAirCon.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

let FGAirConTemp_unknown = NSNotFound

public enum FGAirConTempUnit : Int {
    case _unknown
    case _C
    case _F
    case sasa
}


class FGAirCon: FGComponent {
    
    /** A/C is turned on or off. */
    var isOn: Bool = false
    
    /** A/C fan speed. */
    //var currentFanSpeed: FGAirConFanSpeed!
    
    /** Current *ROOM* temperature from thermostat. This is NOT the temperature set on A/C.
     Unknown value is represented as NSNotFound. */
    var currentTemperature: Float = 0.0

    /** A/C target temperature.
     Unknown value is represented as NSNotFound. */
    var targetTemperature: Float = 0.0
    
    static var tempSendToHubFormat: String = "%.02f"
    
    /** The temperature min value in Celsius. */
    var minTemp: Float = 0.0
    /** The temperature max value in Celsius. */
    var maxTemp: Float = 0.0
    /** The temperature steps. */
    var tempStep: Float = 0.0
    /** The temperature to start with. Default is NSNotFound, meaning unknown temperature. */
    var defaultTemp: Float?{
        get{
            return Float(FGAirConTemp_unknown)
        }
    }
    /** If YES, fan control slider should be hidden and replaced with a plain on/off switch. */
    var isFanControlDisabled: Bool = false
    /** FGAirConFanSpeed objects. */
    var fanSpeeds = [Any]()
    /** FGAirConMode objects. */
    var modes = [Any]()
    /** Current mode */
    //var currentMode: FGAirConMode!
    
    override init(dictionary: Dictionary<String, Any>) {
        /*if !(dict is [AnyHashable: Any]) {
            return nil
        }*/
        super.init(dictionary: dictionary)
        
        self.currentTemperature = self.defaultTemp!
        self.targetTemperature = self.defaultTemp!
        
    }
    
    override var type: NSString?{
        get{
            return "AC"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
    
    func tempRange() -> Float {
        return self.maxTemp - self.minTemp
    }
    
    func capTemp(withinRange rawTemp: Float) -> Float {
        return max(min(rawTemp, self.maxTemp), self.minTemp)
    }
    
    /*override func addMessageObservers() {
        super.addMessageObservers()
        // must call super
        self.device.room.onCommands(FGCommand(action: "POWER", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            self.isOn = msg.argument(atIndex: 1).isEqual(toStringCaseInsensitive: "ON")
        })
        self.device.room.onCommandsAction("THERMOSTAT", firstArgument: self.uid, callback: {(_ msg: FGCommand) -> Void in
            if msg.argument(atIndex: 1).toNSNumber() {
                var newTemp = CFloat(msg.argument(atIndex: 1))
                newTemp = self.capTemp(withinRange: newTemp)
                self.targetTemperature = newTemp
            }
        })
        self.device.room.onCommandsAction("TEMP", firstArgument: self.uid, callback: {(_ msg: FGCommand) -> Void in
            if msg.argument(atIndex: 1) {
                var newTemp = CFloat(msg.argument(atIndex: 1))
                newTemp = self.capTemp(withinRange: newTemp)
                self.currentTemperature = newTemp
            }
        })
        self.device.room.onCommandsAction("FAN", firstArgument: self.uid, callback: {(_ msg: FGCommand) -> Void in
            var cmd: String = msg.argument(atIndex: 1)
            if cmd != "" {
                var s: FGAirConFanSpeed? = self.fanSpeed(fromCommandName: cmd)
                if s != nil {
                    self.currentFanSpeed = s
                }
            }
        })
    }*/
    
    /*func powerOffFanSpeed() -> FGAirConFanSpeed {
        for s: FGAirConFanSpeed in self.fanSpeeds {
            if s.powerOff {
                return s
            }
        }
        return nil
    }
    
    func fanSpeed(fromCommandName commandName: String) -> FGAirConFanSpeed {
        for s: FGAirConFanSpeed in self.fanSpeeds {
            if s.command.isEqual(toStringCaseInsensitive: commandName) {
                return s
            }
        }
        return nil
    }*/
    
    override func setupComponent(withConfig config: [AnyHashable: Any]) {
        self.minTemp = CFloat(config["min_temperature_celsius"] as! NSNumber)
        self.maxTemp = CFloat(config["max_temperature_celsius"] as! NSNumber)
        self.tempStep = CFloat(config["step_temperature_celsius"] as! NSNumber)
        self.isFanControlDisabled = config["fan_control_disabled"] as! Bool
        var fanSpeedsRaw: [Any] = config["fanspeeds"] as! [Any]
        //self.fanSpeeds = FGAirConFanSpeed.objects(withArray: fanSpeedsRaw)
        var modesRaw: [Any] = config["modes"] as! [Any]
        //self.modes = FGAirConMode.objects(withArray: modesRaw)
    }

    // MARK: - sending command
    /*
    func send(_ speed: FGAirConFanSpeed) {
        if speed {
            var previousSpeed: FGAirConFanSpeed? = self.currentFanSpeed
            // now is turned on, send before set fan speed
            if speed.powerOff == false {
                if previousSpeed == nil || previousSpeed?.powerOff == true {
                    self.sendTurn(on: true)
                }
            }
            var m = FGCommand(action: "FAN", argument: self.uid, argument: speed.command)
            if self.room.hub.write(m) {
                self.currentFanSpeed = speed
            }
            // now is turned off, send after set fan speed
            if speed.powerOff {
                if previousSpeed == nil || previousSpeed?.powerOff == false {
                    self.sendTurn(on: false)
                }
            }
        }
    }
    
    func sendTargetTemperature(_ temp: Float) {
        temp = self.capTemp(withinRange: temp)
        var m = FGCommand(action: "THERMOSTAT", argument: self.uid, argument: String(format: tempSendToHubFormat, temp))
        // wait for command echo to set temperature
        self.room.hub.write(m)
        //    // don't wait for command echo
        //    if ([m send]) {
        //        self.ac.currentTemperature = temp;
        //    }
    }
    
    func sendTurn(on: Bool) {
        var m = FGCommand(action: "POWER", argument: self.uid, argument: on ? "ON" : "OFF")
        if self.room.hub.write(m) {
            self.isOn = on
        }
    }
    
    func send(_ mode: FGAirConMode) {
        var modeCommand = FGCommand(action: "MODE", argument: self.uid, argument: mode.command)
        if self.room.hub.write(modeCommand) {
            self.currentMode = mode
        }
    }*/
    
    // MARK: - temp unit
    
    func tempUnits() -> [FGAirConTempUnit] {
        return [._C, ._F]
    }
    
    class func convertCelsius(_ celsius: Float, to unit: FGAirConTempUnit) -> Float {
        if celsius == Float(FGAirConTemp_unknown) {
            return Float(FGAirConTemp_unknown)
        }
        switch unit {
            case ._C:
                return celsius
            case ._F:
                return (celsius * 9.0 / 5.0) + 32.0
            default:
                return Float(FGAirConTemp_unknown)
        }
        
    }
    
    class func unitString(from unit: FGAirConTempUnit) -> String? {
        switch unit {
            case ._C:
                return "°C"
            case ._F:
                return "°F"
            default:
                return nil
        }
        
    }
    
    class func description(from unit: FGAirConTempUnit) -> String? {
        switch unit {
            case ._C:
                return "Celsius (C)"
            case ._F:
                return "Fahrenheit (F)"
            default:
                return nil
        }
        
    }
    
    class func saveTempUnit(toUserDefaults unit: FGAirConTempUnit) {
        UserDefaults.standard.set(unit, forKey: FGAirConTempUnitKey)
        UserDefaults.standard.synchronize()
    }
    
    class func loadTempUnitFromUserDefaults() -> FGAirConTempUnit {
        return FGAirConTempUnit(rawValue: UserDefaults.standard.integer(forKey: FGAirConTempUnitKey))!
    }
}
