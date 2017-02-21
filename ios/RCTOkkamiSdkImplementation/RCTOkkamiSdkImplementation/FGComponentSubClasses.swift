//
//  FGComponentSubClasses.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

public func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension FGComponent {
    
    class func allSubclasses() -> [AnyClass] {
        var result: [AnyClass]? = nil
        /* TODO: move below code to the static variable initializer (dispatch_once is deprecated) */
        ({() -> Void in
            // *** List all FGComponentBase subclasses here. Yeah, I know... ***
            result = [FGLight.self, FGRadio.self, FGAirCon.self, FGTV.self, FGCurtain.self]
        })()
        return result!
    }
}

/** Represents a "Light" type component. */
class FGLight : FGComponent{
    
    /** Light is turned on or off. */
    private var isOn : Bool?
    /** Light is a dimmable light or not. */
    private var isDimmable : Bool = false
    /** Light current brightness. */
    private var _brightness : Int = 0
    private var brightness : Int?{
        get{
            return _brightness
        }
        set{
            let min : Int = self.brightnessRange.location
            if(newValue! < min){
                _brightness = min
            }else{
                let max : Int = self.brightnessRange.location + self.brightnessRange.length
                if(newValue! > max){
                _brightness = max
                }
            }
            _brightness = brightness!
        }
    }
    /** Light brightness range, hardcoded to return `NSMakeRange(0, 255)` */
    private var brightnessRange : NSRange{
        get{
            return NSRange(location: 0, length: 255)
        }
    }
    /** Light color parsed from "color" config, default is [UIColor whiteColor]. */
    private var color : UIColor = UIColor.white
    
    /** Sends command to turn component on/off. */
    private func sendTurnOn(on: Bool){
        /*var m = FGCommand(action: "POWER", argument: self.uid, argument: on ? "ON" : "OFF")
        if self.room.hub.write(m) {
            self.isOn = on
        }*/
    }
    /** Sends command to change component brightness. */
    private func sendBrightness(value: Int){
        /*var m = FGCommand(action: "DIM", argument: self.uid, argument: "\(value)")
        if self.room.hub.write(m) {
            self.brightness = value
        }*/
    }
    /** Self-Master Light Check. */
    private func isMasterLight()->Bool{
        return self.uid!.isEqual(to: "light-master")
    }
    /** Self-Service Light Check. */
    private func isServiceLight()->Bool{
        return self.uid!.isEqual(to: "service_light")
    }
    
    override init(dictionary: Dictionary<String, Any>) {
        super.init(dictionary: dictionary)
        self.isDimmable = self.config?["dimmable"] as! Bool
        self.color = hexStringToUIColor(hex: self.config?["color"] as! String)
    }
    
    override var type: NSString?{
        get{
            return "Light"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
    
    /*public override func getType()->NSString{
        return "Light"
    }*/
    
    //addMesageObserver not yet implemented
    /*override func addMessageObservers() {
        super.addMessageObservers()
        // must call super
        //    POWER light-1 ON
        self.device.room.onCommands(FGCommand(action: "POWER", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            self.isOn = msg.argument(atIndex: 1).isEqual(toStringCaseInsensitive: "ON")
        })
        //    DIM light-1 DOWN 99   // same as DIM light-1 99
        //    DIM light-1 UP 99     // same as DIM light-1 99
        //    DIM light-1 99
        //    DIM light-1 MAX
        //    DIM light-1 MIN
        self.device.room.onCommands(FGCommand(action: "DIM", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            var argAtIndex1: String = msg.argument(atIndex: 1)
            if argAtIndex1 != "" {
                var argAtIndex2: String = msg.argument(atIndex: 2)
                if argAtIndex2 != "" {
                    if argAtIndex1.isEqual(toStringCaseInsensitive: "UP") {
                        self.brightness = (argAtIndex2 as NSString).integerValue
                    }
                    else if argAtIndex1.isEqual(toStringCaseInsensitive: "DOWN") {
                        self.brightness = (argAtIndex2 as NSString).integerValue
                    }
                }
                else {
                    if argAtIndex1.isEqual(toStringCaseInsensitive: "MIN") {
                        self.brightness = Int(self.brightnessRange.location)
                    }
                    else if argAtIndex1.isEqual(toStringCaseInsensitive: "MAX") {
                        self.brightness = Int(self.brightnessRange.location) + Int(self.brightnessRange.length)
                    }
                    else {
                        if NSString_hasOnly0To9(argAtIndex1) {
                            self.brightness = (argAtIndex1 as NSString).integerValue
                        }
                    }
                }
            }
        })
    }*/
}

/** Represents a "Radio" type component. */
class FGRadio : FGComponent{
    
    /** Current channel number */
    private var currentChannelNo : NSString?
    /** List of all channels */
    private var channels : NSArray?
    
    override var type: NSString?{
        get{
            return "Radio"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
    /*public override func getType()->NSString{
        return "Radio"
    }*/
    
    //addMesageObserver not yet implemented
    /*override func addMessageObservers() {
        super.addMessageObservers()
        // must call super
        self.device.room.onCommandsAction("SWITCH_CHANNEL", firstArgument: self.uid, callback: {(_ msg: FGCommand) -> Void in
            if msg.arguments.count >= 2 {
                self.currentChannelNo = msg.arguments[1]
            }
        })
        self.device.room.onCommandsAction("UPDATE_CHANNELS_LIST", firstArgument: self.uid, callback: {(_ msg: FGCommand) -> Void in
            if msg.arguments.count >= 2 {
                var channels: [Any] = msg.arguments[NSRange(location: 1, length: msg.arguments.count - 1).location..<NSRange(location: 1, length: msg.arguments.count - 1).location + NSRange(location: 1, length: msg.arguments.count - 1).length]
                self.channels = channels
            }
        })
    }*/
}

/** Represents a "Curtain" type component. */
class FGCurtain : FGComponent{
    /*public override func getType()->NSString{
        return "Curtain"
    }*/
    override var type: NSString?{
        get{
            return "Curtain"
        }
        set{
            if (newValue is NSString!) {
                self.type = newValue
            }
        }
    }
}

class FGComponentSubClasses: NSObject {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
}
