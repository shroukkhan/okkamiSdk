//
//  FGMood.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

let FGMoodTag_enter_room = "enter_room"
let FGMoodTag_exit_room = "exit_room"
/** This class parses and stores details and messages of a mood. */
class FGMood: FGIconDictObject {
    var name: String = ""
    var detail: String = ""
    var tag: String = ""
    /** FGCommand objects which can be sent to setup room to match the mood detail. */
    var commands = [Any]()
    /** Sends all ther receiver's commands. */
    var cmdTimer: Timer!
    
    class func object(withDictionary dict: [AnyHashable: Any]) -> FGMood? {
        if !(dict is [AnyHashable: Any]) {
            return nil
        }
        let obj = FGMood()
        obj.name = dict["name"] as! String
        obj.detail = dict["description"] as! String
        obj.tag = dict["tag"] as! String
        //obj.commands = FGCommand.multipleCommands(from: dict["value"] as! NSString)
        //obj.iconName = dict["icon"] as! String
        return obj
    }
    
    class func objects(withArray array: [AnyObject]) -> [AnyObject]? {
        if !(array is Array) {
            return nil
        }
        if array.count == 0 {
            return nil
        }
        var a: NSObject? = array[0] as? NSObject
        
        // type 3: newest version, unflatten version, each mood comes as a dictionary
        if (a is [AnyHashable: Any]) {
            var moods = [Any]() /* capacity: array.count */
            for d in array {
                let mood = FGMood.object(withDictionary: d as! [AnyHashable : Any])
                if (mood != nil) {
                    moods.append(mood!)
                }
            }
            return [Any](arrayLiteral: moods) as [AnyObject]?
        }
        //    // type 2: new version, each mood comes as an array
        //    if ([a isKindOfClass:[NSArray class]]) {
        //        int numMoods = array.count;
        //        NSMutableArray *moods = [NSMutableArray arrayWithCapacity:numMoods];
        //        for (int i = 0; i < numMoods; i++) {
        //            NSArray *ma = array[i];
        //            FGMood *mood = [[FGMood alloc] initWithArray:ma];
        //            [moods addObject:mood];
        //        }
        //        return [NSArray arrayWithArray:moods];
        //    }
        //
        //    // type 1: old version, ALL moods are in ONE looooong array
        //    if ([a isKindOfClass:[NSString class]]) {
        //        int numMoods = array.count/elementIndex_count;
        //        NSMutableArray *moods = [NSMutableArray arrayWithCapacity:numMoods];
        //        for (int i = 0; i < numMoods; i++) {
        //            NSArray *a = [array subarrayWithRange:NSMakeRange(elementIndex_count * i, elementIndex_count)];
        //            FGMood *mood = [[FGMood alloc] initWithArray:a];
        //            [moods addObject:mood];
        //        }
        //        return [NSArray arrayWithArray:moods];
        return nil
    }
    
    static var iconDictBuiltIn: [AnyHashable: Any]?{
        get{
            let lockQueue = DispatchQueue(label: "self")
            lockQueue.sync {
                if self.iconDictBuiltIn == nil {
                    self.iconDictBuiltIn = ["builtin:mood_guitar": UIImage.init(named:"icon_md_guitar")!, "builtin:mood_sun": UIImage.init(named:"icon_md_sun")!, "builtin:mood_moon": UIImage.init(named:"icon_md_moon")!, "builtin:mood_enter_room": UIImage.init(named:"icon_md_enter")!, "builtin:mood_exit_room": UIImage.init(named:"icon_md_exit")!, "builtin:mood_smile": UIImage.init(named:"icon_md_smile")!]
                }
            }
            return self.iconDictBuiltIn!
        }set{
            self.iconDictBuiltIn = newValue
        }
    }
    
    class func defaultIcon() -> UIImage {
        return UIImage.init(named: "icon_md_smile")!
    }
    // MARK: - other
    
    func sendAllCommands() {
        //FGLogInfoWithClsName("sending all commands of mood: %@", self.name)
        //    // send all at once
        //    for (FGCommand *c in self.commands) {
        //        [[FGSession shared].selectedEntity.room.hub writeCommand:c];
        //    }
        // delay between each command
        self.cmdTimer.invalidate()
        var commandCount: Int = 0
        
        /*self.cmdTimer = Timer.bk_scheduledTimer(withTimeInterval: 0.1, block: {(_ timer: Timer) -> Void in
            // time delay between each command
            if commandCount >= self.commands.count {
                self.cmdTimer.invalidate()
                return
            }
            var c: FGCommand? = self.commands[commandCount]
            FGSession.shared().selectedEntity.room.hub.write(c)
            commandCount += 1
        }, repeats: true)*/
    }
    override var description : String {
        return "[<\(NSStringFromClass(self.self as! AnyClass))> name:\(self.name)]"
    }
}
