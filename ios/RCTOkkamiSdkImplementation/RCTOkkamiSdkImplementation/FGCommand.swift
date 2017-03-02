//
//  FGCommand.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Log
import CryptoSwift

public func authSignatureWithString(data : String, key : String) -> String{
    let bytes: Array<UInt8> = Array(data.utf8)
    let secKey: Array<UInt8> = Array(key.utf8)
    var hmac = ""
    do {
        hmac = try HMAC(key: secKey, variant: .sha1).authenticate(bytes).toHexString()
    }catch{
        
    }
    return hmac
}

class FGCommand: NSObject {
    
    let Log = Logger()
    
    var kArgSeperator: String = " "
    // e.g. space
    var kPipeCharacter: String = "|"

    /** Command action */
    var action: String = ""
    /** Command arguments */
    var arguments = [Any]()
    /** Command headers in front of pipe character. This will nil if there is a
     pipe but nothing in front of it.
     */
    var pipeHeaders = [Any]()
    
    init?(action: String, arguments: [Any]) {
        // Look in arguments for the first '|' (pipe) character,
        // we should discard anything before and including it.
        // Any pipe after is considered a normal argument.
        var _action = action
        var _arguments = arguments
        var pipeLocation: Int = -1
        for i in 0..<arguments.count {
            var s: String = arguments[i] as! String
            s = s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (s == kPipeCharacter) {
                pipeLocation = i
                break
            }
        }
        if pipeLocation >= 0 {
            let newStart: Int = pipeLocation + 1
            let newPipeHeaders: [Any] = [action] + arguments[NSRange(location: 0, length: pipeLocation).location..<NSRange(location: 0, length: pipeLocation).location + NSRange(location: 0, length: pipeLocation).length]
            if newPipeHeaders.count > 0 {
                self.pipeHeaders = newPipeHeaders
            }
            var newParts = arguments[NSRange(location: newStart, length: arguments.count - newStart).location..<NSRange(location: newStart, length: arguments.count - newStart).location + NSRange(location: newStart, length: arguments.count - newStart).length]
            // don't recurse with [FGCommand commandWithArray:newParts]; cuz it will cut da pipe again!
            if newParts.count == 0 {
                return nil
            }
            else {
                var newArgs : Any?
                if newParts.count > 1 {
                    newArgs = newParts[NSRange(location: 1, length: newParts.count - 1).location..<NSRange(location: 1, length: newParts.count - 1).location + NSRange(location: 1, length: newParts.count - 1).length]
                }
                _action = newParts[0] as! String 
                _arguments = newArgs as! [Any]
            }
        }
        
        // -----------------
        // Validate action
        _action = _action.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (_action.characters.count ) == 0 {
            return nil
        }
        // Validate arguments
        var mArgs = [String]()
        var dummy: String? = nil
        for a in _arguments {
            // trim whitespace
            var trimmed: String = (a as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            // -----------------
            // stick quoted strings together
            if !(dummy != nil) && trimmed.begins(with: "\"") {
                // start quoted string
                // remove start quote
                trimmed = (trimmed as NSString).replacingOccurrences(of: "\"", with: "", options: [], range: NSRange(location: 0, length: 1))
                dummy = trimmed
            }
            else if dummy != nil {
                if trimmed.ends(with: "\"") && !trimmed.ends(with: "\\\"") {
                    // end quoted string
                    // remove end quote
                    trimmed = (trimmed as NSString).replacingOccurrences(of: "\"", with: "", options: [], range: NSRange(location: (trimmed.characters.count ) - 1, length: 1))
                    dummy! += "\(kArgSeperator)\(trimmed)"
                    // exit
                    if dummy!.characters.count > 0 {
                        mArgs.append(dummy!)
                    }
                    dummy = nil
                }
                else {
                    dummy! += "\(kArgSeperator)\(trimmed)"
                }
            }else{
                if trimmed.characters.count > 0 {
                    mArgs.append(trimmed)
                }
            }
        }
        var noEscapedCharArgs = [String]()
        for arg: String in mArgs {
            var new: String = arg.replacingOccurrences(of: "\\\"", with: "\"")
            new = new.replacingOccurrences(of: "\\\\", with: "\\")
            noEscapedCharArgs.append(new)
        }
        mArgs = noEscapedCharArgs
        super.init()
        
        self.action = action
        self.arguments = [Any](arrayLiteral: mArgs)
    }
    
    convenience init?(array parts: [String]) {
        if parts.count == 0 {
            return nil
        }
        var arguments: [Any] = []
        if parts.count > 1 {
            let indeks = NSRange(location: 1, length: parts.count - 1).location..<NSRange(location: 1, length: parts.count - 1).location + NSRange(location: 1, length: parts.count - 1).length
            arguments = Array(parts[indeks])
        }
        
        self.init(action: parts[0], arguments: arguments)
    }
    override init(){
        super.init()
    }
    
    convenience init?(action: String, argument: String) {
        let args: [String] = FGCommand().array(fromArg: argument, arg: nil)
        self.init(action: action, arguments: args)
    }
    
    convenience init?(action: String, argument: String, argument argument2: String) {
        let args: [String] = FGCommand().array(fromArg: argument, arg: argument2)
        self.init(action: action, arguments: args)
    }
    
    convenience init?(string: String) {
        // validate string
        var _string = string
        var action: String = ""
        var arguments: [String] = []
        _string = _string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var comps: [String] = string.components(separatedBy: FGCommand().kArgSeperator)
        if comps.count > 0 {
            action = comps[0]
        }
        if comps.count > 1 {
            let range = NSRange(location: 1, length: comps.count - 1)
            arguments = Array(comps[range.location..<range.location + range.length])
        }
        self.init(action: action, arguments: arguments)
    }
    
    convenience init?(data: Data) {
        let line = String(data: data, encoding: String.Encoding.utf8)
        self.init(string: line!)
    }
    // MARK: - private
    
    func array(fromArg a1: String, arg a2: String?) -> [String] {
        var m = [String]()
        if a1 != "" {
            m.append(a1)
        }
        if a2 != "" {
            m.append(a2!)
        }
        return m
    }
    // MARK: - Interfaces
    func plainString() -> String {
        var pipeHeaders: String = (self.pipeHeaders as NSArray).componentsJoined(by: kArgSeperator)
        if pipeHeaders.characters.count > 0 {
            pipeHeaders = pipeHeaders.appendingFormat("%@%@%@", kArgSeperator, kPipeCharacter, kArgSeperator)
        }
        else {
            pipeHeaders = ""
        }
        return "\(pipeHeaders)\(self.plainStringWithoutPipeHeaders())"
    }
    
    func plainStringWithoutPipeHeaders() -> String {
        var args: String = (self.arguments as NSArray).componentsJoined(by: kArgSeperator)
        if args.characters.count > 0 {
            return "\(self.action)\(kArgSeperator)\(args)"
        }
        return self.action
    }
    /** final data for write should have @"\r\n" at the end. */
    
    func dataForWrite() -> Data {
        // self.plainString will never have terminator at the end, so no need to check
        let terminator: String = "\r\n"
        let stringForWrite = self.plainString() + terminator
        return stringForWrite.data(using: String.Encoding.utf8)!
    }
    override var description: String {
        return "[<\(self)> \(self.plainString())]"
    }
    
    func firstArgument() -> String {
        return self.argument(at: 0)!
    }
    
    func secondArgument() -> String {
        return self.argument(at: 1)!
    }
    
    func argument(at index: Int) -> String? {
        return (self.arguments.count > index) ? self.arguments[index] as? String : nil
    }
    
    func multipleCommands(from stringDividedBy_bsR_bsN: String) -> [Any] {
        let comps: [String] = stringDividedBy_bsR_bsN.components(separatedBy: "\r\n")
        var messages = [Any]() /* capacity: comps.count */
        for str: String in comps {
            let command = FGCommand(string: str)
            if command != nil {
                messages.append(command!)
            }
        }
        return [Any](arrayLiteral: messages)
    }
    
    func addArgument(_ arg: String) {
        /*if NSString_hasString(arg) {
            self.arguments = self.arguments + [arg]
        }*/
        self.arguments = self.arguments + [arg]
    }
    
    func addSignature(withAuthSecret secret: String) {
        let sig = authSignatureWithString(data: self.plainString(), key: secret)
        var m: String = "FGCommand adding signature:"
        m += "\n string: \(self.plainString)"
        m += "\n secret: \(secret)"
        m += "\n result: \(sig)"
        Log.debug(m)
        self.addArgument(sig)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        // Can't compare self.plainString anymore since there's nonce and pipeHeaders mess.
        // We have to explicitly compare action and arguments.
        let message = object as! FGCommand
        return self.isActionEqual(message.action) && self.argumentsEqual(message.arguments)
    }
    
    
    func isContaining(_ message: FGCommand) -> Bool {
        if message.isActionEqual(self.action) {
            // check that all parameter message.arguments is also in self.arguments
            if message.arguments.count <= self.arguments.count {
                for i in 0..<message.arguments.count {
                    if !(message.arguments[i] as! FGCommand).isEqual(self.arguments[i]) {
                        return false
                    }
                }
                return true
            }
        }
        return false
    }
    
    func isActionEqual(_ action: String) -> Bool {
        return self.action.lowercased().isEqual(action.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }
    
    func pipeHeadersContain(_ headers: [Any]?) -> Bool {
        if headers != nil && self.pipeHeaders.count >= headers!.count {
            // loop receiver headers
            for i in 0...self.pipeHeaders.count - headers!.count {
                // loop matcher headers
                var isAllMatched: Bool = true
                for j in 0..<headers!.count {
                    if !(self.pipeHeaders[i + j] as! FGCommand).isEqual(headers![j]) {
                        isAllMatched = false
                        break
                    }
                }
                if isAllMatched {
                    return true
                }
            }
        }
        return false
    }
    // internal
    
    func argumentsEqual(_ args: [Any]) -> Bool {
        if self.arguments.count == args.count {
            for i in 0..<self.arguments.count {
                if !(self.arguments[i] as! FGCommand).isEqual(args[i]) {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    // MARK: - NSCopying
    /*override func copy(with zone: NSZone? = nil) -> Any {
        var m = FGCommand(action: self.action.copy(with zone: zone), arguments: self.arguments.copy(with zone: zone))
        return m
    }*/
    
}
