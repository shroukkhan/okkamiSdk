//
//  FGLog.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
/*
// Error Codes
let FG_ErrorCode_NoInternetConnection = 100
let FG_ErrorCode_NotConnectedToRoom = 101
let FG_ErrorCode_InvalidParameter = 102
let FG_ErrorCode_RequestFailed = 400
let FG_ErrorCode_Unauthorized = 401
let FG_ErrorCode_InvalidResponse = 406
let FG_ErrorCode_ResponseHasErrorKey = 407
let FG_ErrorCode_RequestTimeout = 408
let FG_ErrorCode_HubSyncTimeError = 409
let FG_ErrorCode_InvalidSignature = 410
let FG_ErrorCode_CannotParseResponse = 422
let FG_ErrorCode_Cancelled = 440
// Notification
let FGLOG_UPDATED_NOTIFICATION = "FGLogUpdatedNotification"
// Easy-to-understand error messages
let FG_WarnMsgForDummies_Offline = NSLocalizedString("Offline - please try again later.", comment: "warning msg")
let FG_ErrorMsgForDummies_NoRoomFound = NSLocalizedString("There's a problem while getting information for your room.", comment: "error msg")
let FG_ErrorMsgForDummies_RoomConnectFailed = NSLocalizedString("There's a problem while connecting to your room.", comment: "error msg")
let FG_ErrorMsgForDummies_TechnicalIssueTryAgain = NSLocalizedString("There's a technical issue. Please try again.", comment: "error msg")
let FG_buttonTitle_OK = NSLocalizedString("OK", comment: "alert button")
let FG_buttonTitle_Cancel = NSLocalizedString("Cancel", comment: "alert button")
let FG_buttonTitle_Retry = NSLocalizedString("Retry", comment: "alert button")
let FGLogVerbose(__FORMAT__, ...)   [[FGLog shared] newLogVerboseWithFormat:__FORMAT__, ##__VA_ARGS__]
let FGLogInfo(__FORMAT__, ...)      [[FGLog shared] newLogInfoWithFormat:__FORMAT__, ##__VA_ARGS__]
let FGLogWarn(__FORMAT__, ...)      [[FGLog shared] newLogWarnWithFormat:__FORMAT__, ##__VA_ARGS__]
let FGLogError(__FORMAT__, ...)     [[FGLog shared] newLogErrorWithFormat:__FORMAT__, ##__VA_ARGS__]

// Log with class name, e.g. "[FGPresets] - my awesome presets"
let FGLogVerboseWithClsName(__FORMAT__, ...)    [[FGLog shared] newLogVerboseWithFormat:[NSString stringWithFormat:@"%@ - "__FORMAT__, [self class], ##__VA_ARGS__]]
let FGLogInfoWithClsName(__FORMAT__, ...)       [[FGLog shared] newLogInfoWithFormat:[NSString stringWithFormat:@"%@ - "__FORMAT__, [self class], ##__VA_ARGS__]]
let FGLogWarnWithClsName(__FORMAT__, ...)       [[FGLog shared] newLogWarnWithFormat:[NSString stringWithFormat:@"%@ - "__FORMAT__, [self class], ##__VA_ARGS__]]
let FGLogErrorWithClsName(__FORMAT__, ...)      [[FGLog shared] newLogErrorWithFormat:[NSString stringWithFormat:@"%@ - "__FORMAT__, [self class], ##__VA_ARGS__]]

// Log with class and function name in front, e.g. "-[FGPresets moodWithName:] - my awesome mood name"
let FGLogVerboseWithClsAndFuncName(__FORMAT__, ...) [[FGLog shared] newLogVerboseWithFormat:[NSString stringWithFormat:@"%s - "__FORMAT__, __func__, ##__VA_ARGS__]]
let FGLogInfoWithClsAndFuncName(__FORMAT__, ...)    [[FGLog shared] newLogInfoWithFormat:[NSString stringWithFormat:@"%s - "__FORMAT__, __func__, ##__VA_ARGS__]]
let FGLogWarnWithClsAndFuncName(__FORMAT__, ...)    [[FGLog shared] newLogWarnWithFormat:[NSString stringWithFormat:@"%s - "__FORMAT__, __func__, ##__VA_ARGS__]]
let FGLogErrorWithClsAndFuncName(__FORMAT__, ...)   [[FGLog shared] newLogErrorWithFormat:[NSString stringWithFormat:@"%s - "__FORMAT__, __func__, ##__VA_ARGS__]]

// Log level
let FGLOG_FLAG_ERROR    (1 << 0)  // 0...0001
let FGLOG_FLAG_WARN     (1 << 1)  // 0...0010
let FGLOG_FLAG_INFO     (1 << 2)  // 0...0100
let FGLOG_FLAG_VERBOSE  (1 << 3)  // 0...1000
let FGLOG_LV_OFF     0
let FGLOG_LV_ERROR   (FGLOG_FLAG_ERROR)                                                           // 0...0001
let FGLOG_LV_WARN    (FGLOG_FLAG_ERROR | FGLOG_FLAG_WARN)                                         // 0...0011
let FGLOG_LV_INFO    (FGLOG_FLAG_ERROR | FGLOG_FLAG_WARN | FGLOG_FLAG_INFO)                       // 0...0111
let FGLOG_LV_VERBOSE (FGLOG_FLAG_ERROR | FGLOG_FLAG_WARN | FGLOG_FLAG_INFO | FGLOG_FLAG_VERBOSE)  // 0...1111
let FGLOG_ERROR   ([FGLog shared].logLevel & FGLOG_FLAG_ERROR)
let FGLOG_WARN    ([FGLog shared].logLevel & FGLOG_FLAG_WARN)
let FGLOG_INFO    ([FGLog shared].logLevel & FGLOG_FLAG_INFO)
let FGLOG_VERBOSE ([FGLog shared].logLevel & FGLOG_FLAG_VERBOSE)
//let CACHE_ROOT_FOLDER = "com.fingi.iossdk/FGLog"

class FGLog: NSObject {
    /** FGLogString objects of all log history.
     @see FGLogString */
    var logs = [Any]()
    /** Max amount of logs. Default is 128. We caps the max amount of logs to save memory. */
    var maxLogCount: Int = 0
    /** Log level, default is FGLOG_LV_INFO */
    var logLevel: Int = 0
    
    var mLogs = [Any]()
    var identifierCounter: UInt = 0

    /** A shared object.
     @returns A shared object.
     */
    
    class func shared() -> FGLog {
        var shared: FGLog? = nil
        /* TODO: move below code to the static variable initializer (dispatch_once is deprecated) */
        ({() -> Void in
            shared = FGLog()
        })()
        return shared!
    }
    
    override init() {
        super.init()
        
        identifierCounter = 0
        self.maxLogCount = 512
        self.logLevel = FGLOG_LV_INFO
        mLogs = [Any]() /* capacity: self.maxLogCount */
        
    }
    
    func logs() -> [Any] {
        return [Any](arrayLiteral: mLogs)
    }
    
    func logs(forSentry numberOfLogs: Int) -> [Any] {
        var m = [Any]()
        if numberOfLogs > self.logs().count {
            numberOfLogs = self.logs().count
        }
        for i in 0..<numberOfLogs {
            var s: FGLogString? = self.logs()[i]
            m.append(s?.description)
        }
        return m
    }
    // MARK: - export
    
    func rootCachePath() -> String {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var path: String = paths[0]
        path = URL(fileURLWithPath: path).appendingPathComponent(CACHE_ROOT_FOLDER).absoluteString
        return path
    }
    
    func exportFilePath() -> String {
        var info: String = "\(NSBundle_infoFromKey("CFBundleDisplayName")) (\(NSBundle_infoFromKey("CFBundleIdentifier")))-\(NSBundle_infoFromKey("CFBundleShortVersionString"))(\(NSBundle_infoFromKey("CFBundleVersion")))"
        var fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH-mm-ssZ"
        var filename: String = "\(info) [\(fmt.string(from: Date()))].log"
        var filePath: String = URL(fileURLWithPath: self.rootCachePath()).appendingPathComponent(filename).absoluteString
        return filePath
    }
    
    func exportLogs() -> String {
        var m = String()
        for s: FGLogString in self.logs {
            m += "\(s.description)\n"
        }
        return m
    }
    
    func exportLogsToCachesDirectory() -> String {
        var filePath: String = self.exportFilePath()
        var string: String = self.exportLogs()
        var error: Error?
        if filePath.createDirectoryPathToFileIfNotExists() == false {
            return nil
        }
        var ok: Bool? = try? string.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        if ok == nil {
            // an error occurred
            FGLogError("Error writing file at %@\n%@", filePath, error?.userInfo)
            return nil
        }
        return filePath
    }
    let PARSE_VA_LIST = va_list, format * m
    let lvName_verbose: String = "VERBOSE"
    let lvName_info: String = "INFO"
    let lvName_warning: String = "WARNING"
    let lvName_error: String = "ERROR"
    let lvName_unknown: String = "UNKNOWN"

    
    class func name(fromLevel fgLogLevel: Int) -> String {
        switch fgLogLevel {
        case FGLOG_LV_VERBOSE:
            return lvName_verbose
        case FGLOG_LV_INFO:
            return lvName_info
        case FGLOG_LV_WARN:
            return lvName_warning
        case FGLOG_LV_ERROR:
            return lvName_error
        default:
            return lvName_unknown
        }
        
    }
    
    func newLogError(withFormat format: String) {
        if FGLOG_ERROR {
            var PARSE_VA_LIST
            var ls = FGLogString(string: m, level: FGLOG_LV_ERROR)
            self.addLogStringHistory(ls)
        }
    }
    
    func newLogWarn(withFormat format: String) {
        if FGLOG_WARN {
            var PARSE_VA_LIST
            var ls = FGLogString(string: m, level: FGLOG_LV_WARN)
            self.addLogStringHistory(ls)
        }
    }
    
    func newLogInfo(withFormat format: String) {
        if FGLOG_INFO {
            var PARSE_VA_LIST
            var ls = FGLogString(string: m, level: FGLOG_LV_INFO)
            self.addLogStringHistory(ls)
        }
    }
    
    func newLogVerbose(withFormat format: String) {
        if FGLOG_VERBOSE {
            var PARSE_VA_LIST
            var ls = FGLogString(string: m, level: FGLOG_LV_VERBOSE)
            self.addLogStringHistory(ls)
        }
    }
    
    func addLogStringHistory(_ ls: FGLogString) {
        if (ls is FGLogString) {
            self.willChangeValue(forKey: "logs")
            if mLogs.count >= self.maxLogCount {
                mLogs.removeLast()
            }
            ls.identifier = identifierCounter += 1
            mLogs.insert(ls, at: 0)
            self.didChangeValue(forKey: "logs")
            print("\(ls.descriptionWithoutDate())")
            NotificationCenter.default.post(name: FGLOG_UPDATED_NOTIFICATION, object: ls)
        }
    }
    
    func clearLogs() {
        mLogs.removeAll()
    }
}

class FGLogString: NSObject {
    /** Log message. */
    var string: String = ""
    /** Create date. */
    var date: Date!
    /** Log level. */
    var level: Int = 0
    /** Log identifier. */
    var identifier: UInt = 0
    /** For convenience. Formatted date string in format @"yyyy-MM-dd HH:mm:ss.SSS" */
    
    convenience init(string: String, level: Int) {
        var new = FGLogString()
        if new {
            new.string = string
            new.date = Date()
            new.level = level
        }
        return new
    }
    
    func dateDisplay() -> String {
        var fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        return fmt.string(from: self.date)
    }
    
    func timeDisplay() -> String {
        var fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ss"
        return fmt.string(from: self.date)
    }
    
    override func description() -> String {
        return "[\(self.dateDisplay())] \(FGLog.name(fromLevel: self.level)): \(self.string)"
    }
    
    func descriptionWithoutDate() -> String {
        return "\(FGLog.name(fromLevel: self.level)): \(self.string)"
    }
}*/
