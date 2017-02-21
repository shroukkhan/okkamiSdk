//
//  FGHelper.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/18/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation

extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func firstCharacter() -> String? {
        if (self as NSString).length > 0 {
            return (self as NSString).substring(to: 1)
        }
        else {
            return nil
        }
    }
    
    func lastCharacter() -> String? {
        if (self as NSString).length > 0 {
            return (self as NSString).substring(from: (self as NSString).length - 1)
        }
        else {
            return nil
        }
    }
    
    func begins(with string: String) -> Bool {
        let lowercaseSelf: String = (self as NSString).lowercased
        var lowercaseStr: String = string.lowercased()
        if (lowercaseSelf == lowercaseStr) {
            return true
        }
        else if (lowercaseStr.characters.count) > 0 && (self as NSString).length >= (lowercaseStr.characters.count) {
            return ((lowercaseSelf as NSString).substring(to: (lowercaseStr.characters.count )) == lowercaseStr)
        }
        else {
            return false
        }
        
    }
    
    func ends(with string: String) -> Bool {
        var lowercaseSelf: String = (self as NSString).lowercased
        var lowercaseStr: String = string.lowercased()
        if (lowercaseSelf == lowercaseStr) {
            return true
        }
        else if (lowercaseStr.characters.count ) > 0 && (lowercaseSelf.characters.count ) >= (lowercaseStr.characters.count ) {
            return ((lowercaseSelf as NSString).substring(from: (lowercaseSelf.characters.count) - (lowercaseStr.characters.count)) == lowercaseStr)
        }
        else {
            return false
        }
        
    }
    
    func contains(_ string: String) -> Bool {
        let lowercaseSelf: String = (self as NSString).lowercased
        let lowercaseStr: String = string.lowercased()
        return (lowercaseSelf.range(of: lowercaseStr) != nil)
    }
    
    func isValidEmail() -> Bool {
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    func isEqual(toStringCaseInsensitive string: String) -> Bool {
        return ((self as NSString).lowercased == string.lowercased())
    }
    
    init?(object: Any) {
        self.init()
        if (object is NSNull) {
            return nil
        }
        self.appending("\(object)")
    }
    
    func parenthesized() -> String {
        return "(\(self))"
    }
    
    func isEmpty() -> Bool {
        return (self as NSString).length == 0
    }
    
    func urlParametersParsing() -> [AnyHashable: Any] {
        var result: Dictionary<String,Any>?
        let splitedParams: [Any] = self.components(separatedBy: "&")
        for param in splitedParams {
            let keyValueSplited: [Any] = (param as! String).components(separatedBy: "=")
            result?["\(keyValueSplited.first)"] = keyValueSplited.last
        }
        return result!
    }
    
    func decodingURLRawString() -> String {
        return self.replacingOccurrences(of: "+", with: " ").replacingPercentEscapes(using: String.Encoding.utf8)!
    }
    
    func removeLeadingZero() -> String {
        if self.firstCharacter() == "0" {
            return ((self as NSString).substring(from: 1))
        }
        return self as String
    }
    
    func string(byReplacingURLOccurrencesOf target: String, with replacement: String) -> String {
        // safeguard
        /*if NSString_hasString(target) == false {
            
        }
        if NSString_hasString(replacement) == false {
            replacement = "null"
        }*/
        var _replacement = replacement
        _replacement = _replacement.addingPercentEscapes(using: String.Encoding.utf8)!
        var mutableSelf: String = self as String
        mutableSelf = mutableSelf.replacingOccurrences(of: target, with: _replacement)
        return mutableSelf
    }
    
    func arrayFromCommaSeperatedString() -> [Any] {
        let comps: [Any] = self.components(separatedBy: ",")
        var m = [Any]()
        for c in comps {
            var trimmed: String = (c as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (trimmed.characters.count ) > 0 {
                m.append(trimmed)
            }
            //if (max > 0 && m.count >= max) break; // cap to max
        }
        return [Any](arrayLiteral: m)
    }
}

extension NSMutableString {
    
    func append(withNewLineIfNeeded aString: String) {
        if self.length == 0 {
            self.append(aString)
        }
        else {
            self.append("\n\(aString)")
        }
    }
}

extension Date {
    // string -> date
    
    static func fromRFC3339String (string: String) -> Date {
        NSTimeZone.resetSystemTimeZone()
        // Use lower-case z because it can parse both timezone +0700 and +07:00 (colon in middle).
        // The result date will be in GMT.
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        // note: this cannot parse milliseconds!
        let index = string.index(string.startIndex, offsetBy: (string.characters.count)-1)
        
        if string[index] == "Z" {
            fmt.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        }
        var date: Date? = fmt.date(from: string)
        // if it doesn't work, try with milliseconds
        if date == nil {
            fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
            date = fmt.date(from: string)
        }
        return date!
    }
    // date -> string
    
    func rfc3339String() -> String {
        return self.rfc3339String(with: NSTimeZone.system as NSTimeZone)
    }
    func rfc3339String(with timeZone: NSTimeZone) -> String {
        NSTimeZone.resetSystemTimeZone()
        let fmt = DateFormatter()
        fmt.timeZone = timeZone as TimeZone!
        if timeZone.secondsFromGMT == 0 {
            fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            // @"2013-03-19T07:00:00Z" (UTC)
            let string: String = fmt.string(from: self as Date)
            return string
        }
        else {
            fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            // @"2013-03-19T14:00:00+0700" (add timezone colon later)
            let string: String = fmt.string(from: self as Date)
            // add colon to timezone
            var mu: String = string
            mu.insert(":", at: mu.index(mu.startIndex, offsetBy: 22))
            //mu.insert(":", at: 22)
            return mu
        }
    }
    static func timeZone(fromRFC3339String string: String) -> NSTimeZone? {
        if (string.characters.count ) < 20 {
            return nil
        }
        let index = string.index(string.startIndex, offsetBy: 19)
        if string[index] == "Z" {
            return NSTimeZone(forSecondsFromGMT: 0)
        }
        var isNegative: Bool
        if string[index] == "+" {
            isNegative = false
        }
        else if string[index] == "-" {
            isNegative = true
        }
        else {
            return nil
        }
        
        var timeZoneString: String? = (string as NSString).substring(from: 20)
        timeZoneString = timeZoneString?.replacingOccurrences(of: ":", with: "")
        // remove colon
        if (timeZoneString?.characters.count ?? 0) != 4 {
            return nil
        }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        let offsetHour = CUnsignedInt(f.number(from: ((timeZoneString as NSString?)?.substring(with: NSRange(location: 0, length: 2)))!)!)
        let offsetMinute = CUnsignedInt(f.number(from: ((timeZoneString as NSString?)?.substring(with: NSRange(location: 2, length: 2)))!)!)
        let isNeg = CUnsignedInt(isNegative ? -1:1)
        let twoOffset = (offsetHour * 3600) + (offsetMinute * 60)
        let multiply = isNeg * twoOffset
        return NSTimeZone(forSecondsFromGMT: Int(multiply))
    }
    // change timezone portion in string to Z (UTC) and left other parts untouched
    // change timezone portion in string to Z (UTC) and left other parts untouched
    
    static func removeTimeZone(fromRFFGC3339String string: String) -> String? {
        if string == nil || !(string is String) {
            return nil
        }
        var comp: [Any] = string.components(separatedBy: "T")
        if comp.count != 2 || ((comp[1] as? String)?.characters.count ?? 0) < 8 {
            return nil
        }
        let time: String? = (comp[1] as? NSString)?.substring(to: 8)
        return "\(comp[0])T\(time)Z"
    }
    // MARK: - date conversion
    // for setting alarm in future, typically with specified hour and minute
    
    func nearestFutureWithSameTimeOfDay() -> Date {
        let dayInterval: TimeInterval = self.timeIntervalSince(self.startOfDate())
        let now = Date()
        let startOfToday = Date().startOfDate()
        var targetTime = Date(timeInterval: dayInterval, since: startOfToday)
        if targetTime.compare(now) == .orderedAscending {
            // past
            targetTime = Date(timeInterval: dayInterval, since: now.startOfTomorrowDate())
        }
        return targetTime
    }
    // Change date to first second of the day
    // 21 Dec 2011 3:08:03 PM -> 21 Dec 2011 12:00:00 AM
    
    func startOfDate() -> Date {
        let calendar = Calendar.current
        let unitFlags : Set<Calendar.Component> = [Calendar.Component.year, .month, .day]
        var breakdownInfo: DateComponents? = calendar.dateComponents(unitFlags, from: self)
        breakdownInfo?.hour = 0
        breakdownInfo?.minute = 0
        breakdownInfo?.second = 0
        return calendar.date(from: breakdownInfo!)!
    }
    // 21 Dec 2011 3:08:03 PM -> 21 Dec 2011 3:08:00 PM
    // 21 Dec 2011 3:08:03 PM -> 21 Dec 2011 3:08:00 PM
    
    func startOfMinute() -> Date {
        let calendar = Calendar.current
        let unitFlags : Set<Calendar.Component> = [Calendar.Component.year, .month, .day, .hour, .minute]
        var breakdownInfo: DateComponents? = calendar.dateComponents(unitFlags, from: self)
        breakdownInfo?.second = 0
        return calendar.date(from: breakdownInfo!)!
    }
    // Change date to last second of the day
    // 21 Dec 2011 3:08:03 PM -> 21 Dec 2011 11:59:59 PM
    
    func endOfDate() -> Date {
        let calendar = Calendar.current
        let unitFlags : Set<Calendar.Component> = [Calendar.Component.year, .month, .day]
        var breakdownInfo: DateComponents? = calendar.dateComponents(unitFlags, from: self)
        breakdownInfo?.hour = 23
        breakdownInfo?.minute = 59
        breakdownInfo?.second = Int(59.9)
        return calendar.date(from: breakdownInfo!)!
    }
    // return rounded down date at 5 min interval
    // 21 Dec 2011 3:08:03 PM -> 22 Dec 2011 3:05:00 PM
    
    func roundDown5MinInterval() -> Date {
        let calendar = Calendar.current
        let unitFlags : Set<Calendar.Component> = [Calendar.Component.year, .month, .day, .hour, .minute]
        var breakdownInfo: DateComponents? = calendar.dateComponents(unitFlags, from: self)
        breakdownInfo?.minute = (Int((breakdownInfo?.minute)! / 5)) * 5
        breakdownInfo?.second = 0
        return calendar.date(from: breakdownInfo!)!
    }
    // Change date to first second of the day
    // 21 Dec 2011 3:08:03 PM -> 22 Dec 2011 12:00:00 AM
    func startOfTomorrowDate() -> Date {
        let calendar = Calendar.current
        let unitFlags : Set<Calendar.Component> = [Calendar.Component.year, .month, .day]
        var breakdownInfo: DateComponents? = calendar.dateComponents(unitFlags, from: self)
        breakdownInfo?.setValue(1, for: .day)
        breakdownInfo?.hour = 0
        breakdownInfo?.minute = 0
        breakdownInfo?.second = 0
        let date: Date = Date()
        return calendar.date(byAdding: breakdownInfo!, to: date)!
    }
    
    init(hour: Int, minute: Int) {
        self.init(hour: hour, minute: minute, timeZone: NSTimeZone.system as NSTimeZone)
    }
    
    init(hour: Int, minute: Int, timeZone: NSTimeZone) {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = timeZone as TimeZone
        self = gregorian.date(from: comps)!
    }
    
    static func dateInSameTime(with timeZone: NSTimeZone) -> Date {
        NSTimeZone.resetSystemTimeZone()
        let dateInSameTimeInGMT = Date().addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
        return dateInSameTimeInGMT.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT))
    }
    
    
    func isSame(as date: Date) -> Bool {
        return (self.compare(date) == .orderedSame)
    }
    
    func isEarlierThanDate(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    func isLaterThanDate(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
}

extension Timer {
    class func bk_executeBlockBlockFromTimer(aTimer: Timer) {
    }
}
extension Timer {
    
    class func bk_scheduledTimer(with inTimeInterval: TimeInterval, block: @escaping (_ timer: Timer) -> Void, repeats inRepeats: Bool) -> Any {
        assert(block != nil, "Invalid parameter not satisfying: block != nil")
        return self.scheduledTimer(timeInterval: inTimeInterval, target: self, selector: #selector(self.bk_executeBlockFromTimer), userInfo: block, repeats: inRepeats)
    }
    
    class func bk_timer(with inTimeInterval: TimeInterval, block: @escaping (_ timer: Timer) -> Void, repeats inRepeats: Bool) -> Any {
        assert(block != nil, "Invalid parameter not satisfying: block != nil")
        return self.init(timeInterval: inTimeInterval, target: self, selector: #selector(self.bk_executeBlockFromTimer), userInfo: block, repeats: inRepeats)
    }
    
    class func bk_executeBlockFromTimer(aTimer: Timer, completion: @escaping (Any) ->Void) {
        let block = aTimer.userInfo
        if block != nil {
            completion(block as Any)
        }
    }
}

extension Array {
    
    /*func membersAreKindOf(_ c: AnyClass) -> Bool {
        let mirror = Mirror(reflecting: c)
        if self.count == 0 {
            return false
        }
        for obj in self {
            if !((obj as! AnyClass) == mirror.subjectType) {
                return false
            }
        }
        return true
    }
    
    func object(atIndexNilIfNotExist index: Int) -> Any? {
        if 0 <= index && index < self.count {
            return self[index]
        }
        else {
            return nil
        }
    }
    
    func filteredArrayForKind(of aClass: AnyClass) -> [Any] {
        let mirror = Mirror(reflecting: aClass)
        var m = [Any]() /* capacity: self.count */
        for o: AnyObject in self {
            if (o.isKind(of: mirror.subjectType)) {
                m.append(o)
            }
            else {
                //FGLogWarnWithClsAndFuncName("member \"%@\", at index %ld, is not kind of class \"%@\"", o, UInt(self as NSArray).index(of: o), NSStringFromClass(aClass))
            }
        }
        return [Any](arrayLiteral: m)
    }*/
}

class FGHelper: NSObject {
    
}
