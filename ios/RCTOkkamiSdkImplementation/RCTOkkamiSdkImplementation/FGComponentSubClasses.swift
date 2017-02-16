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
            var min : Int = self.brightnessRange.location
            if(brightness! < min){
                brightness = min
            }else{
                var max : Int = self.brightnessRange.location + self.brightnessRange.length
                if(brightness! > max){
                    brightness = max
                }
            }
            _brightness = brightness!
        }
    }
    /** Light brightness range, hardcoded to return `NSMakeRange(0, 255)` */
    private var brightnessRange : NSRange{
        get{
            return NSMakeRange(0, 255)
        }
    }
    /** Light color parsed from "color" config, default is [UIColor whiteColor]. */
    private var color : UIColor = UIColor.white
    /** Sends command to turn component on/off. */
    private func sendTurnOn(on: Bool){
        /*FGCommand *m = [FGCommand commandWithAction:@"POWER"
        argument:self.uid
        argument:on ? @"ON" : @"OFF" ];
        if ([self.room.hub writeCommand:m]) {
            _isOn = on;
        }*/
    }
    /** Sends command to change component brightness. */
    private func sendBrightness(value: Int){
        /*FGCommand *m = [FGCommand commandWithAction:@"DIM"
        argument:self.uid
        argument:[NSString stringWithFormat:@"%d",value]];
        if ([self.room.hub writeCommand:m]) {
            _brightness = value;
        }*/
    }
    /** Self-Master Light Check. */
    private func isMasterLight()->Bool{
        return self.uid.isEqual(to: "light-master")
    }
    /** Self-Service Light Check. */
    private func isServiceLight()->Bool{
        return self.uid.isEqual(to: "service_light")
    }
    
    override init(dictionary: Dictionary<String, Any>) {
        super.init(dictionary: dictionary)
        self.isDimmable = self.config?["dimmable"] as! Bool
        self.color = hexStringToUIColor(hex: self.config?["color"] as! String)
    }
    
    
    public override func getType()->NSString{
        return "Light"
    }
    
    
    //addMesageObserver not yet implemented
}

/** Represents a "Radio" type component. */
class FGRadio : FGComponent{
    
    /** Current channel number */
    private var currentChannelNo : NSString?
    /** List of all channels */
    private var channels : NSArray?
    
    public override func getType()->NSString{
        return "Radio"
    }
    
    //addMesageObserver not yet implemented
}

/** Represents a "Curtain" type component. */
class FGCurtain : FGComponent{
    public override func getType()->NSString{
        return "Curtain"
    }
}

class FGComponentSubClasses: NSObject {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
}
