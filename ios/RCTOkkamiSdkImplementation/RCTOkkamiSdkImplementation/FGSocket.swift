//
//  FGSocket.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit


/** Default read timeout. 10 seconds. */
let kFGSocketReadTimeout: TimeInterval = 15.0

/** Notification name when a command is written. An error is sent if writing fails.
 userInfo: @{@"socket":FGSocket, @"cmd":FGCommand, @"error":NSError} */
let FGSocketNotificationNameCommandDidWrite: String = "FGSocketNotificationNameCommandDidWrite"

/** Notification name when a command is read.
 userInfo: @{@"socket":FGSocket, @"cmd":FGCommand} */
let FGSocketNotificationNameCommandDidRead: String = "FGSocketNotificationNameCommandDidRead"

// seconds

let kFGSocketWriteTimeout: TimeInterval = 10.0

let kFGSocketPingInterval: TimeInterval = 30.0

let kFGSocketPongWaitTimeout: TimeInterval = 7.0

let kFGSocketPingRetryMaxCount: Int = Int(2.0)

// number of retry before force disconnect
let kTagCmd_default: Int = 0

// default tag for commands when write/read
// commands
let FGSocketCmdActionPING: String = "PING"

let FGSocketCmdActionPONG: String = "PONG"

let FGSocketCmdActionReload: String = "RELOAD"

let FGSocketCmdActionCheckMove: String = "CHECK_MOVE"

let FGSocketCmdActionCheckOut: String = "CHECKOUT"

let ENABLE_PING_PONG_LOGGING = false

/** This class wraps all socket writing and reading with socket. (e.g. Turning on lights.)
 
 * Integrates tightly with FGCommand.
 * Utilizes CocoaAsyncSocket and also adds the concept of soft timeouts to it.
 * There are observer methods built in for you (THObserver object) to help observing when your
 interested command arrives.
 */

class FGSocket: NSObject {
    
    /*
    /** Hub base URL. Default is @"https://hub.fingi.com" */
    var baseURL: String = "https://hub.fingi.com"
    /** Hub port. Default is 20020 */
    var port: Int = 20020
    /** Specifies if socket is connected or not */
    var isConnected: Bool = false
    /** The last command sent OR received. */
    var lastCommand: FGCommand?
    /** The last command received. */

    var lastCommandRead: FGCommand? {
        get {
            // TODO: add getter implementation
        }
        set(cmd) {
            if (cmd != nil) {
                self.lastCommandRead = cmd
                self.lastCommand = cmd
                var center = NotificationCenter.default
                center.post(name: NSNotification.Name(rawValue: FGSocketNotificationNameCommandDidRead), object: self, userInfo: ["socket": self, "cmd": cmd])
                self.respond(toMessageRead: cmd!)
            }
        }
    }
    var listenHello: FGCommandListener?
    var listenIdentified: FGCommandListener?
    var listenPong: FGCommandListener?
    var pingTimer: Timer?
    var originalURL: URL?
    var pingRetryCount: Int = 0
    var helloRetryCount: Int = 0
    
    
    /** The last command sent. */
    var lastCommandWrite: FGCommand?
    /** The room that socket connection is in */
    var room: FGRoom?
    /** Enables Ping Pong command logging when send/receive. Default is NO. */
    var isEnablePingPongLogging: Bool = false
    
    //var socket: GCDAsyncSocket?
    
    var connectHubBlock: ((AnyObject, NSError) -> Void)? = nil
    var disconnectHubBlock: ((AnyObject, NSError) -> Void)? = nil
    var identifyDeviceIDBlock: ((AnyObject, NSError) -> Void)? = nil
    
    var completionBlock: ((AnyObject, NSError) -> Void)? = nil
    var nonce: Int = 0
    var mockHubConnected: Bool = false
    var isRetryingHello: Bool = false
    
    
    override init() {
        super.init()
        self.isEnablePingPongLogging = ENABLE_PING_PONG_LOGGING
        //self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        self.mockHubConnected = false
        self.resetNonceCounter()
        
    }
    
    func shouldLogCommand(_ command: FGCommand) -> Bool {
        if self.isEnablePingPongLogging == false {
            /*if command.isActionEqual(FGSocketCmdActionPING) || command.isActionEqual(FGSocketCmdActionPONG) {
                return false
            }*/
        }
        return true
    }
    
 */
    /*func connectToHub() {
        // avoid multiple run at the same time
        //FGLogInfo("*** Connecting to HUB: %@", FGSession.shared().hubURL)
        var writeErr: Error? = nil
        self.disconnect(withCallback: nil)
        // initialize, and also for safety
        // Remove URL scheme from the original URL.
        // e.g. change @"https://hub.fingi.com" to @"hub.fingi.com"
        // https protocal handling with be checked using `originalURL` again later on.
        // See in `-socket:didConnectToHost:port:` method.
        self.originalURL = FGSession.sharedInstance.hubURL
        var URLString: String? = self.originalURL?.absoluteString
        var dividerRange: NSRange = (URLString? as NSString).rangeOf("://")
        var divider: Int = NSMaxRange(dividerRange)
        if divider == NSNotFound {
            divider = 0
        }
        var URLNoScheme: String? = (URLString as? NSString)?.substring(from: divider)
        var suffixDividerRange: NSRange = (URLNoScheme? as NSString).rangeOf(":", options: .backwards)
        var URLNoSuffix: String? = URLNoScheme
        if suffixDividerRange.location != NSNotFound {
            URLNoSuffix = (URLNoScheme as? NSString)?.substring(to: suffixDividerRange.location)
        }
        //FGLogInfo("*** Connecting to HUB: %@", URLNoSuffix)
        var hubConnectOK: Bool? = try! self.socket.connect(toHost: URLNoSuffix, on: FGSession.shared().hubPort, withTimeout: 60)
        // success operation is in -socketDidSecure:
        if hubConnectOK == nil {
            var err = Error.fingiError(withCode: FG_ErrorCode_NoInternetConnection, description: "*** Cannot connect to HUB, socket error")
            try! self.runConnectHubBlock()
        }
    }
    func identifyDeviceID(_ deviceID: String, callback block: FGErrorBlock) {
        if self.identifyDeviceIDBlock {
            return
        }
        // avoid multiple run at the same time
        self.identifyDeviceIDBlock = block
        if deviceID == "" {
            var err = Error.fingiError(withCode: FG_ErrorCode_InvalidParameter, description: "*** Cannot connect to HUB, no device ID to identify")
            try! self.runIdentifyDeviceIDBlock()
            return
        }
        // Send IDENTIFY
        // Format IDENTIFY string as follows...
        // `nonce uid mode | IDENTIFY timestamp signature`
        // `1002 gcc-1 device | IDENTIFY 1377241498 239f2a1178421b5c65b3bdacf5783245dd`
        var mode: String = "device"
        var pipeHeaders: [Any] = [self.nonce(), deviceID, mode]
        var m = FGCommand(array: ["IDENTIFY", String.timestampUTC()])
        m.pipeHeaders = pipeHeaders
        m.addSignature(withAuthSecret: self.room.auth.secret)
        self.write(m)
        // Setup listener
        var cmds: [Any] = [FGCommand(string: "IDENTIFIED"), FGCommand(string: "ERROR")]
        self.listenIdentified = FGCommandListener(self, commands: cmds, timeout: kFGSocketReadTimeout, exactMatch: false, delegate: self)
    }
    
    func retryHello() {
        self.isRetryingHello = true
        self.disconnect(withCallback: nil)
        var t: TimeInterval = self.exponentialRetryTime(for: self.helloRetryCount)
        //FGLogWarnWithClsName("Hub busy, disconnected socket and retrying in %.1f sec (attempt %lu)", t, UInt(self.helloRetryCount))
        self.performSelector(#selector(self.connectToHubWithCallback), withObject: self.connectHubBlock, afterDelay: t)
    }
    
    func listener(_ listener: FGCommandListener, foundMatchedIdx idx: Int, receivedCommand cmd: FGCommand, orStoppedWithError err: Error?) {
        // HELLO
        if listener == self.listenHello {
            if err != nil {
                try! self.runConnectHubBlock()
                return
            }
            if idx == 0 {
                // Server is connected as normal. Sweet.
                try! self.runConnectHubBlock()
            }
            else if idx == 1 {
                // Server detected itself under load so all new connections will be discarded until resources becomes available again.
                // Clients should retry the connection using exponentially-increasing timeout as to not flood the already-flooded hub.
                // - When received E_THROTTLE on connect to hub, disconnect and reconnect with exponentially increasing timeout.
                if listener == self.listenHello {
                    if (cmd.action == "ERROR") {
                        var error: Error? = nil
                        if (cmd.arguments.first == "E_THROTTLE") {
                            if self.helloRetryCount < 5 {
                                self.retryHello()
                                if self.isRetryingHello {
                                    self.helloRetryCount += 1
                                }
                            }
                            else {
                                self.isRetryingHello = false
                                error = Error.fingiError(withCode: FG_ErrorCode_RequestTimeout, description: "Hub busy (keep getting E_THROTTLE response)", recovery: "The server is busy right now. Please try again later.")
                                FGLogErrorWithClsName("Hub busy (keep getting E_THROTTLE response)")
                            }
                        }
                        else if (cmd.arguments.first == "E_TIME") {
                            error = Error.fingiError(withCode: FG_ErrorCode_HubSyncTimeError, description: "Time out of sync (E_TIME)", recovery: "Your device time is too different from server. Please adjust your time and try again.")
                            FGLogErrorWithClsName("Time out of sync (E_TIME)")
                        }else if (cmd.arguments.first == "E_INVALID_SIGNATURE") {
                            error = Error.fingiError(withCode: FG_ErrorCode_InvalidSignature, description: "Invalid Signature (E_INVALID_SIGNATURE)", recovery: "Authentication failed. Please contact support.")
                            //FGLogErrorWithClsName("Invalid Signature (E_INVALID_SIGNATURE)")
                        }
                        try! self.runConnectHubBlock()
                    }
                }else if listener == self.listenIdentified {
                    if err != nil {
                        self.disconnect(withCallback: nil)
                        try? self.runIdentifyDeviceIDBlock()
                        return
                    }
                    if idx == 0 {
                        // connect to CORE and hub success
                        self.startPingTimer()
                        try? self.runIdentifyDeviceIDBlock()
                    }
                    else if idx == 1 {
                        // disconnect
                        self.disconnect(withCallback: nil)
                        var error = Error.fingiError(withCode: FG_ErrorCode_RequestTimeout, description: cmd.plainStringWithoutPipeHeaders())
                        try? self.runIdentifyDeviceIDBlock()
                    }
                }else if listener == self.listenPong {
                    // fail
                    if err != nil {
                        self.pingRetryCount += 1
                        if self.pingRetryCount > kFGSocketPingRetryMaxCount {
                            self.pingRetryCount = 0
                            self.stopPingTimerAndReconnect()
                        }
                        else {
                            self.stopPingTimer()
                            var t: TimeInterval = self.exponentialRetryTime(for: self.pingRetryCount)
                            self.bk_performBlock({(_ obj: Any) -> Void in
                                self.pingAndListen()
                            }, afterDelay: t)
                        }
                        return
                    }
                    // success
                    self.pingRetryCount = 0
                    self.startPingTimer()
                }
            }
        }
    }
    
    // called when...
    // - reconnect failed and tap disconnect
    // - disconnect confirmed
    // - simulate hub disconnect
    
    func disconnect(withCallback block: FGErrorBlock) {
        if self.disconnectHubBlock {
            return
        }
        self.disconnectHubBlock = block
        self.socket.disconnect()
        self.initializeSession()
        self.mockHubConnected = false
        #if MOCK_HUB_LOGIN_RESPONSE
            self.socketDidDisconnect(self.socket, withError: nil)
        #endif
    }
    // main write
    
    func write(_ cmd: FGCommand) -> Bool {
        var center = NotificationCenter.default
        if !FGReachability.isReachable() {
            var err = Error.fingiError(withCode: FG_ErrorCode_NoInternetConnection, description: "write command failed, no internet connection", recovery: FG_WarnMsgForDummies_Offline)
            FGLogWarn(err.localizedDescription)
            center.post(name: FGSocketNotificationNameCommandDidWrite, object: self, userInfo: ["socket": self, "cmd": cmd, "error": err])
            return false
        }
        if !self.isConnected {
            var err = Error.fingiError(withCode: FG_ErrorCode_NotConnectedToRoom, description: "write command failed, device is not connected to room", recovery: FG_WarnMsgForDummies_Offline)
            FGLogWarn(err.localizedDescription)
            center.post(name: FGSocketNotificationNameCommandDidWrite, object: self, userInfo: ["socket": self, "cmd": cmd, "error": err])
            return false
        }
        // Looks like GCDAsyncSocket write timeout is not working, and will never work.
        // http://stackoverflow.com/questions/15550942/gcdasyncsocket-write-timeout-does-not-work
        self.socket.writeData(cmd.dataForWrite, with: kFGSocketWriteTimeout, tag: kTagCmd_default)
        self.lastCommandWrite = cmd
        if self.shouldLogCommand(cmd) {
            FGLogInfo(">  write to hub: %@", cmd.plainString)
        }
        return true
    }
    // simulate hub read

    func simulateRead(fromHub cmd: FGCommand) {
        FGLogInfo("< read from hub: (simulated) %@", cmd.plainString)
        self.lastCommandRead = cmd
    }
    
    func simulateUnexpectedHubDisconnect(withDescription desc: String) {
        self.socket.delegate = nil
        // temporarily override delegate
        self.disconnectHubBlock = nil
        self.disconnect(withCallback: nil)
        self.socket.delegate = self
        self.socketDidDisconnect(self.socket, withError: Error.fingiError(withCode: FG_ErrorCode_NoInternetConnection, description: desc))
    }
    // read WITHOUT timeout, all are partial matching
    
    func onAnyCommand(withCallback block: FGCommandOnlyBlock) -> THObserver {
        return self.onCommands(withObject: nil, callback: block)
    }
    
    func onCommands(_ cmd: FGCommand, callback block: FGCommandOnlyBlock) -> THObserver {
        if !cmd {
            return nil
        }
        return self.onCommands(withObject: cmd, callback: block)
    }
    
    func onCommandsAction(_ action: String, callback block: FGCommandOnlyBlock) -> THObserver {
        if !NSString_hasString(action) {
            return nil
        }
        return self.onCommands(withObject: action, callback: block)
    }
    
    func onCommandsAction(_ action: String, firstArgument arg: String, callback block: FGCommandOnlyBlock) -> THObserver {
        if !NSString_hasString(action) {
            return nil
        }
        else {
            if !NSString_hasString(arg) {
                // no arg, fall back to check action only
                return self.onCommandsAction(action, callback: block)
            }
            else {
                return self.onCommands(withObject: [action, arg], callback: block)
            }
        }
    }
    var keyNew: String = "new"
    var keyLastCommand: String = "lastCommand"
    var keyLastCommandRead: String = "lastCommandRead"
    
    func onCommands(withObject object: Any, callback block: FGCommandOnlyBlock) -> THObserver {
        if !FGReachability.isReachableAndShowAlertIfNo() {
            return nil
        }
        var checkObj: Any? = object
        var b: FGCommandOnlyBlock = block
        var observer = THObserver(for: self, keyPath: keyLastCommand, options: NSKeyValueObservingOptionNew, change: {(_ change: [AnyHashable: Any]) -> Void in
            self.trigger(onCommand: change[keyNew], checkObj: checkObj, block: b)
        })
        return observer
    }
    
    func trigger(on m: FGCommand, checkObj: Any, block b: FGCommandOnlyBlock) {
        if (m is FGCommand) {
            if !checkObj {
                BLOCK_SAFE_RUN(b, m)
            }
            else {
                if (checkObj is FGCommand) {
                    if m.isContaining(checkObj) {
                        BLOCK_SAFE_RUN(b, m)
                    }
                }
                else if (checkObj is String) {
                    if m.isActionEqual(checkObj) {
                        BLOCK_SAFE_RUN(b, m)
                    }
                }
                else if (checkObj is [Any]) {
                    // PAIRTIAL match action and 1 argument
                    var array: [Any]? = (checkObj as? [Any])
                    if array?.count > 1 && m.isActionEqual(array[0]) {
                        if m.arguments[0].isEqual(toStringCaseInsensitive: array[1]) {
                            BLOCK_SAFE_RUN(b, m)
                        }
                    }
                }
                else if checkObj == nil {
                    BLOCK_SAFE_RUN(b, m)
                }
            }
        }
    }
    // MARK: - internal
    
    func isConnected() -> Bool {
        var result: Bool = false
        #if MOCK_HUB_LOGIN_RESPONSE
            result = self.mockHubConnected
        #else
            result = self.socket.isConnected()
        #endif
        return result
    }
    // reset variables
    
    func initializeSession() {
        self.bk_removeAllBlockObservers()
        self.lastCommandRead = nil
    }
    // Protocol Formatting
    
    func nonce() -> String {
        return "\(UInt(self.nonce += 1))"
        // increment after use
    }
    
    func resetNonceCounter() {
        self.nonce = 1000
    }
    
    func setLastCommandWrite(_ cmd: FGCommand) {
        if cmd {
            self.lastCommandWrite = cmd
            self.lastCommand = cmd
            var center = NotificationCenter.default
            center.post(name: FGSocketNotificationNameCommandDidWrite, object: self, userInfo: ["socket": self, "cmd": cmd])
        }
    }
    
    func setLastCommandRead(_ cmd: FGCommand) {
        if cmd {
            self.lastCommandRead = cmd
            self.lastCommand = cmd
            var center = NotificationCenter.default
            center.post(name: FGSocketNotificationNameCommandDidRead, object: self, userInfo: ["socket": self, "cmd": cmd])
            self.respond(toMessageRead: cmd)
        }
    }
    // MARK: - GCDAsyncSocketDelegate
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        // automatically starts TLS
        self.secureSocket(sock)
    }
    // We are connecting to server with self-signed certificate and don't include the certificate
    // (public key .pem) in the client. So we skip all the cert checking. To actually check, see
    // http://stackoverflow.com/questions/9874932/ssl-identity-certificate-to-run-an-https-server-on-ios
    
    func secureSocket(_ sock: GCDAsyncSocket) {
        var settings = [AnyHashable: Any]()
        settings[GCDAsyncSocketManuallyEvaluateTrust] = true
        // see GCDAsyncSocket.h
        sock.startTLS(settings)
    }
    
    func socket(_ sock: GCDAsyncSocket, didReceiveTrust trust: SecTrustRef, completionHandler: @escaping (_ shouldTrustPeer: Bool) -> Void) {
        // always trust
        if completionHandler {
            completionHandler(true)
        }
    }
    
    func socketDidSecure(_ sock: GCDAsyncSocket) {
        // start receiving messages
        self.socket.readData(withTimeout: -1, tag: kTagCmd_default)
        if !self.isRetryingHello {
            self.helloRetryCount = 0
        }
        // Setup listener
        var cmds: [Any] = [FGCommand(string: "HELLO"), FGCommand(string: "E_THROTTLE")]
        self.listenHello = FGCommandListener(socket: self, commands: cmds, timeout: kFGSocketReadTimeout, exactMatch: false, delegate: self)
    }
    
    func exponentialRetryTime(forCount count: Int) -> TimeInterval {
        // count : 0,1,2,3,...
        // return: 1,2,4,8,...
        return pow(2, count)
    }
    
    func runConnectHubBlockWithError(_ err: Error?) {
        if err != nil {
            self.disconnect(withCallback: nil)
        }
        BLOCK_SAFE_RUN(self.connectHubBlock, err)
        self.connectHubBlock = nil
    }
    
    func runIdentifyDeviceIDBlockWithError(_ err: Error?) {
        if err != nil {
            self.disconnect(withCallback: nil)
        }
        BLOCK_SAFE_RUN(self.identifyDeviceIDBlock, err)
        self.identifyDeviceIDBlock = nil
    }
    // also called on write fails
    
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if self.connectHubBlock {
            // if connect fail on check-in
            try? self.runConnectHubBlock()
            FGLogWarn("*** HUB disconnected")
        }
        else {
            // unexpected disconnect, reconnect automatically
            // assuming there is no change with room device/component
            if err && self.room.isInConnectedStates {
                //if (err && FG_ISSESSION_OPENED([FGSession shared].state)) {
                FGLogWarn("*** HUB disconnected with error: %@", err)
                FGLogWarn("*** HUB reconnecting...")
                self.room.state = FGRoomStateHubReconnecting
                // It happens when room is moved while phone is in sleep/lock screen.
                // Check if device is still in the same room before reconnect.
                self.room.isDeviceStillInRoom(withCallback: {(_ success: Bool, _ err: Error) -> Void in
                    if success || err {
                        // just reconnect if request failed
                        self.room.reconnectToHubOnly()
                    }
                    else {
                        FGSession.shared().selectedEntity.room.disconnect(withEndState: FGRoomStateDisconnectedByRoomMove, callback: nil)
                    }
                    err = nil
                    // shouldn't display any error
                    BLOCK_SAFE_RUN(self.disconnectHubBlock, err)
                    // err always exists
                    self.disconnectHubBlock = nil
                })
            }
            else {
                // user disconnect
                FGLogInfo("*** HUB disconnected")
                BLOCK_SAFE_RUN(self.disconnectHubBlock, err)
                // err always exists
                self.disconnectHubBlock = nil
            }
        }
        self.stopPingTimer()
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        var string = String(data, encoding: String.Encoding.utf8)
        // multiple FGCommand may come in the same read, need to separate them first
        var allLines: [Any] = string.components(separatedBy: "\r\n")
        for s: String in allLines {
            var cmd = FGCommand(string: s)
            if cmd {
                if self.shouldLogCommand(cmd) {
                    FGLogInfo("< read from hub: %@", cmd.plainString)
                }
                self.lastCommandRead = cmd
            }
        }
        self.socket.readData(withTimeout: -1, tag: kTagCmd_default)
        // always read
    }
    // Keep this comment for future refernce
    // Called when a socket has completed writing the requested data. Not called if it fails.
    // NOTE: Somehow this is called even there is NO internet connection. I guess it just checks that
    // the write reaches the socket writeQueue.
    //- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //    FGLogInfo(@"> didWrite: OK");
    //}
    
    func stopPingTimerAndReconnect() {
        self.stopPingTimer()
        FGLogError("PING timed out, reconnecting to HUB...")
        self.simulateUnexpectedHubDisconnect(withDescription: "ping timed out")
    }
    // MARK: - Ping Pong
    let SIMULATE_PING_TIMEOUT = 0
    
    func startPingTimer() {
        if self.pingTimer {
            self.stopPingTimer()
        }
        #if SIMULATE_PING_TIMEOUT
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 6, block: {(_ time: TimeInterval) -> Void in
                self.stopPingTimerAndReconnect()
            }, repeats: false)
        #else
            self.pingTimer = Timer.bk_scheduledTimer(withTime: kFGSocketPingInterval, block: {(_ timer: Timer) -> Void in
                self.pingAndListen()
            }, repeats: false)
        #endif
    }
    
    
    // Keep this comment for future refernce
    // Called when a socket has completed writing the requested data. Not called if it fails.
    // NOTE: Somehow this is called even there is NO internet connection. I guess it just checks that
    // the write reaches the socket writeQueue.
    //- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //    FGLogInfo(@"> didWrite: OK");
    //}
    
    func stopPingTimerAndReconnect() {
        self.stopPingTimer()
        FGLogError("PING timed out, reconnecting to HUB...")
        self.simulateUnexpectedHubDisconnect(withDescription: "ping timed out")
    }
    // MARK: - Ping Pong
    let SIMULATE_PING_TIMEOUT = 0
    
    func startPingTimer() {
        if self.pingTimer {
            self.stopPingTimer()
        }
        #if SIMULATE_PING_TIMEOUT
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 6, block: {(_ time: TimeInterval) -> Void in
                self.stopPingTimerAndReconnect()
            }, repeats: false)
        #else
            self.pingTimer = Timer.bk_scheduledTimer(withTime: kFGSocketPingInterval, block: {(_ timer: Timer) -> Void in
                self.pingAndListen()
            }, repeats: false)
        #endif
    }
    
    func pingAndListen() {
        var timestamp = String(format: "%.0f", Date().timeIntervalSince1970)
        self.listenPong = FGCommandListener(socket: self, commands: [FGCommand(string: FGSocketCmdActionPONG)], timeout: kFGSocketPongWaitTimeout, exactMatch: false, delegate: self)
        self.writeCommand(FGCommand(action: FGSocketCmdActionPING, argument: timestamp))
    }
    
    func stopPingTimer() {
        self.listenPong.stop()
        self.pingTimer.invalidate()
        self.pingTimer = nil
    }
    // Monitor all socket-lifetime incoming messages

    
    func respond(toMessageRead cmd: FGCommand) {
        // handle ping, format is "PING [time]"
        if cmd.isActionEqual(FGSocketCmdActionPING) {
            var timestamp: String = cmd.argument(atIndex: 0)
            self.writeCommand(FGCommand(action: FGSocketCmdActionPONG, argument: timestamp))
        }
        else if cmd.isActionEqual(FGSocketCmdActionReload) {
            self.room.respondToHubReloadCommand()
        }
        else if cmd.isActionEqual(FGSocketCmdActionCheckMove) {
            self.room.disconnect(withEndState: FGRoomStateDisconnectedByRoomMove, callback: nil)
        }
        else if cmd.isActionEqual(FGSocketCmdActionCheckOut) {
            self.room.disconnect(withEndState: FGRoomStateDisconnectedByCheckOut, callback: nil)
        }
        
    }*/
    
    
}
