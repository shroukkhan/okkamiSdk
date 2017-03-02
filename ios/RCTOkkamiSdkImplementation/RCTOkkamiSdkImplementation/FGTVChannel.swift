//
//  FGTVChannel.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGTVChannel: NSObject {
    /** Channel name */
    var name: String = ""
    /** Channel body */
    var body: String = ""
    /** Channel number assigned by property.
     Other than integers, it also support alphabets. e.g. a1, b1, 20a, 33b. */
    var chNo: String = ""
    /** The raw program ID from provider. */
    var epgID: String = ""
    /** The channel's picture url information. */
    //var picture: FGNodePicture!
    /** The channel's genre. */
    var genre: FGTVGenre!
    /** FGTVProgram objects representing programs in a channel, sorted by timeStart. */
    var programs = [FGTVProgram]()
    /** Sets up channels and programs by merging EPG data into each channel with same `epgID`,
     Programs are sorted by `timeStart`.
     */
    init(dictionary dict: [AnyHashable: Any]) {
        super.init()
        
        self.chNo = String(object: dict["ch_no"]!)!
        // ch_no is string
        let x = (self.chNo as NSString).boolValue
        if !x {
            self.chNo = String(object: dict["ch_id"]!)!
        }
        // temporary backward compatibility
        self.epgID = String(object: dict["epg_id"]!)!
        // ch_no is int
        self.name = String(object: dict["name"]!)!
        //self.picture = FGNodePicture.node(withDictionary: dict["picture"])
        
    }
    
    override var description: String {
        return "[<\(self)> epg_id:\(self.chNo) name:\(self.name)"
    }
    
    func channelArray(_ chArray: [FGTVChannel], mergeEPGFromArray epgArray: [Any]) {
        for c: FGTVChannel in chArray {
            /*if c.genre.property.presets.hardcodedEPGMode {
                var filteredEPGArray: [Any] = epgArray.filtered(using: NSPredicate(block: {(_ epg: FGTVProgram, _ bindings: [AnyHashable: Any]) -> ObjCBool in
                    return (epg.chNo == String(object: c.chNo))
                }))
                c.setupPrograms(withArray: filteredEPGArray)
            }
            else {
                var filteredEPGArray: [Any] = epgArray.filtered(using: NSPredicate(block: {(_ epg: FGTVProgram, _ bindings: [AnyHashable: Any]) -> ObjCBool in
                    return (epg.epgID == c.epgID)
                }))
                c.setupPrograms(withArray: filteredEPGArray)
            }*/
        }
    }
    /** Sorts by timeStart and set receiver's programs. No epgID checking.
     @param array An array of FGTVProgram objects.
     */
    
    func setupPrograms(withArray array: [FGTVProgram]) {
        if array.count > 0 {
            let sortDescriptor = NSSortDescriptor(key: "timeStart", ascending: true)
            let sortDescriptors: [NSSortDescriptor] = [sortDescriptor]
            self.programs = (array as NSArray).sortedArray(using: sortDescriptors) as! [FGTVProgram]
        }
    }
    func currentProgram(forTime date: Date) -> FGTVProgram? {
        if self.programs.count == 0 {
            return nil
        }
        var result: FGTVProgram?
        // first, try to pick by looking for FGTVProgram that has both timeStart and timeEnd
        for p: FGTVProgram in self.programs {
            if p.timeStart != nil && p.timeEnd != nil {
                // if date is between timeStart and timeEnd
                if date.isLaterThanDate(p.timeStart) && date.isEarlierThanDate(p.timeEnd) {
                    result = p
                    break
                }
            }
        }
        // then, if not found, pick by looking at programs with only timeStart and has NO timeEnd
        if result == nil {
            var candidate: FGTVProgram?
            for p: FGTVProgram in self.programs {
                // first date that is more or equal timeStart
                if p.timeStart != nil && p.timeEnd == nil {
                    if date.isEarlierThanDate(p.timeStart) {
                        //NSLog(@"looking at program: %@", p);
                        result = (candidate != nil ? candidate : p)
                        // returns the previous candidate
                        break
                    }
                    else {
                        candidate = p
                    }
                }
            }
        }
        return result!
    }
    
    func nextProgramOfTime(_ date: Date) -> FGTVProgram? {
        if self.programs.count == 0 {
            return nil
        }
        var result: FGTVProgram?
        for p: FGTVProgram in self.programs {
            // first date that is more or equal timeStart
            if (p.timeStart != nil) {
                if date.isEarlierThanDate(p.timeStart) {
                    result = p
                    break
                }
            }
        }
        return result!
    }
    
    func nextProgramOf(_ program: FGTVProgram) -> FGTVProgram? {
        let nextIndex: Int = (self.programs as NSArray).index(of: program) + 1
        if nextIndex >= self.programs.count {
            return nil
            // epg is day by day
        }
        return self.programs[nextIndex]
    }
}
