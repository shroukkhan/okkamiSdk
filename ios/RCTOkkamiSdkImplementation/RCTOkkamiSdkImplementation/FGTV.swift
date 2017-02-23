//
//  FGTV.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGTV: FGComponent {
    
    var isOn: Bool = false
    var isMuted: Bool = false
    
    /** FGTVSource */
    var sources = [Any]()
    var sourceButtonTitle: String = ""
    // Current values
    /*var currentSource: FGTVSource?{
        get{
            return currentSource
        }
        set{
            self.currentSource = newValue
            print("current source: %@", self.currentSource)
        }
     
     }*/
    var currentChannelNo: String?{
        get{
            return self.currentChannelNo
        }set{
            self.currentChannelNo = newValue
            print("%@ - current channel: %@", self, self.currentChannelNo ?? "")
        }
    }
    // App keep track of Channel No
    /*var currentGenre: FGTVGenre?{
        get{
        }
        set{
            if !(newValue is FGTVGenre) {
                return
            }
            self.currentGenre = newValue
            print("%@ - current genre: %@", self, self.currentGenre.name)
        }
    }
     
    */
    var genres : [Any]?{
        get{
            return self.genres
        }set{
            self.genres = newValue
            if genres!.count > 0 {
                /*self.currentGenre = genres[0]
                if !NSString_hasString(self.currentChannelNo) {
                    self.currentChannelNo = self.currentGenre.firstChannelNo
                }*/
            }
        }
    }
    //var tvGenresObsv: THObserver!
    
    override init(dictionary: Dictionary<String, Any>) {
        super.init(dictionary: dictionary)
        
        // NOTE: DO NOT add tvGenresObsv HERE because subviews are not loaded yet
        
    }
    // MARK: - Special component id support
    
    class func realComponentID(fromNodeComponentID nodeComponentID: String) -> String {
        return nodeComponentID.lowercased().replacingOccurrences(of: "gctv-", with: "tv-")
    }
    
    /*class func tvRemoteName(fromNodeComponentID nodeComponentID: String) -> String {
        if nodeComponentID.lowercased().hasPrefix("gctv-") {
            return FGTVRemoteName_fgc_tv
        }
        return nil
    }*/
    
    // MARK: - override
    
    override var type: NSString?{
        get{
            return "TV"
        }
        set{
            self.type = newValue
        }
    }
    
    override func setupComponent(withConfig config: [AnyHashable: Any]) {
        /*self.sources = FGTVSource.objects(with: config["sources"] as! [Any])
        self.sourceButtonTitle = config["source_button_label"] as! String
        if self.sources.count {
            self.currentSource = self.sources()[0]
        }*/
    }
    override func addMessageObservers() {
        super.addMessageObservers()
        // must call super
        // self owns the block, so we have to use weakSelf
        weak var weakSelf = (self)
        /*self.room.onCommands(FGCommand(action: "POWER", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            weakSelf?.isOn = msg.argument(atIndex: 1).isEqual(toStringCaseInsensitive: "ON")
        })
        self.room.onCommands(FGCommand(action: "MUTE", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            weakSelf?.isMuted = msg.argument(atIndex: 1).isEqual(toStringCaseInsensitive: "ON")
        })
        self.room.onCommands(FGCommand(action: "INPUT", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            weakSelf?.currentSource = self.source(fromName: msg.argument(atIndex: 1))
        })
        self.room.onCommands(FGCommand(action: "KEYPAD", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            weakSelf?.updatecurrentChannelNo(withString: msg.argument(atIndex: 1))
        })
        self.room.onCommands(FGCommand(action: "CHANNEL", argument: self.uid), callback: {(_ msg: FGCommand) -> Void in
            weakSelf?.updatecurrentChannelNo(withString: msg.argument(atIndex: 1))
        })*/
    }
    
    func sendTurn(on: Bool) {
        /*var m = FGCommand(action: "POWER", argument: self.uid, argument: on ? "TOGGLE" : "TOGGLE")
        if self.room.hub.write(m) {
            self.isOn = on
        }*/
    }
    
    // MARK: Source

    /*func source(fromName name: String) -> FGTVSource? {
        if name != "" {
            for s: FGTVSource in self.sources() {
                if name.isEqual(toStringCaseInsensitive: s.source) {
                    return s
                }
            }
        }
        return nil
    }*/
    
    /*func send(_ source: FGTVSource) {
        if source {
            if NSString_hasString(source.source) == false {
                FGLogErrorWithClsAndFuncName("not sent, source arg is empty")
                return
            }
            var m = FGCommand(action: "INPUT", argument: self.uid, argument: source.source)
            if self.room.hub.write(m) {
                self.currentSource = source
            }
        }
    }*/
    
    // MARK: Volume
    
    func sendVolUp() {
        if self.isMuted {
            self.sendMute(false)
        }
        //var m = FGCommand(array: ["VOLUME", self.uid, "UP"])
        //self.room.hub.write(m)
    }
    
    func sendVolDown() {
        if self.isMuted {
            self.sendMute(false)
        }
        //var m = FGCommand(array: ["VOLUME", self.uid, "DOWN"])
        //self.room.hub.write(m)
    }
    
    func sendMute(_ mute: Bool) {
        //var m = FGCommand(action: "MUTE", argument: self.uid, argument: mute ? "ON" : "OFF")
        /*if self.room.hub.write(m) {
            self.isMuted = mute
        }*/
    }
    
    // KEYPAD and CHANNEL are handled the same way on FRCD
    
    func sendKeypad(_ key: String) {
        /*if !NSString_hasString(key) {
            return
        }
        var m = FGCommand(action: "KEYPAD", argument: self.uid, argument: key)
        if self.room.hub.write(m) {
            self.updatecurrentChannelNo(with: key)
        }*/
    }
    
    func sendChannelString(_ channel: String) {
        /*if !NSString_hasString(channel) {
            return
        }
        var m = FGCommand(action: "CHANNEL", argument: self.uid, argument: channel)
        if self.room.hub.write(m) {
            self.updatecurrentChannelNo(with: channel)
        }*/
    }
    
    func sendChannelUp() {
        // Type 1: just send CHANNEL UP/DOWN
        /*var m = FGCommand(action: "CHANNEL", argument: self.uid, argument: "UP")
        self.room.hub.write(m)*/
        // Type 2: change channel number according to selected genre channels
        /*NSArray *channels = self.currentGenre.channels;
        int upChannel = 0;
        if (channels.count) {
            upChannel = ((FGTVChannel*)channels[0]).chNo.intValue;
            for (FGTVChannel *c in channels) {
                if (c.chNo.intValue > self.currentChannelNo) {
                    upChannel = c.chNo.intValue;
                    break;
                }
            }
        }
        else {
            upChannel = self.currentChannelNo++;
            if (upChannel > self.maxChannelNo) upChannel = 0;
        }
        [self sendChannelString:[NSString stringWithFormat:@"%d",upChannel]];*/
        
    }
    
    
    func sendChannelDown() {
        // Type 1: just send CHANNEL UP/DOWN
        /*var m = FGCommand(action: "CHANNEL", argument: self.uid, argument: "DOWN")
        self.room.hub.write(m)
        // Type 2: change channel number according to selected genre channels
        NSArray *channels = self.currentGenre.channels;
        int downChannel = 0;
        if (channels.count) {
            downChannel = ((FGTVChannel*)channels.lastObject).chNo.intValue;
            for (FGTVChannel *c in [channels reverseObjectEnumerator]) {
                if (c.chNo.intValue < self.currentChannelNo) {
                    downChannel = c.chNo.intValue;
                    break;
                }
            }
        }
        else {
            downChannel = self.currentChannelNo--;
            if (downChannel < 0) downChannel = self.maxChannelNo;
        }
        [self sendChannelString:[NSString stringWithFormat:@"%d",downChannel]];*/
        
    }
    
    func updatecurrentChannelNo(with string: String) {
        self.currentChannelNo = string
    }
    // MARK: - helper
    
    /*func source(from string: String) -> FGTVSource? {
        for s: FGTVSource in self.sources() {
            if s.source.isEqual(toStringCaseInsensitive: string) {
                return s
            }
        }
        return nil
    }*/
    
}
