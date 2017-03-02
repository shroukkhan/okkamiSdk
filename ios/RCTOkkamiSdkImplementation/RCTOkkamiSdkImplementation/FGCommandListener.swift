//
//  FGCommandListener.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Log
import ReachabilitySwift

@objc protocol FGCommandListenerDelegate: NSObjectProtocol {
    /** Calls when listener did start successfully.
     @param lis The listener. */
    func listenerDidStart(_ lis: FGCommandListener)
    /** Calls when listener found a match, reached timeout error, or failed starting.
     @param lis The listener.
     @param idx The index of matched command. `NSNotFound` if not found.
     @param cmd The matched command. `nil` if not found.
     @param err The error because of timeout.
     */
    
    func listener(_ lis: FGCommandListener, foundMatchedIdx idx: Int, receivedCommand cmd: FGCommand?, orStoppedWithError err: Error?)
}

class FGCommandListener: NSObject {
    var socket: FGSocket?
    var failTimer: Timer?
    var commands = [FGCommand]()
    var delegate: FGCommandListenerDelegate?
    var isExactMatch: Bool = false
    var observerIds = [Any]()
    var timeout = TimeInterval()
    let Log = Logger()
    let reachability = Reachability()!

    convenience init(socket: FGSocket, commands: [Any], timeout: TimeInterval, exactMatch isExactMatch: Bool, delegate: FGCommandListenerDelegate) {
        self.init()
        self.delegate = delegate
        self.socket = socket
        self.isExactMatch = isExactMatch
        //self.commands = commands.filteredArrayForKind(ofClass: FGCommand.self)
        self.timeout = timeout
        self.observerIds = [Any]()
        self.start()
        
    }
    
    convenience init(socket: FGSocket, commands: [Any], exactMatch isExactMatch: Bool, delegate: FGCommandListenerDelegate) {
        self.init(socket: socket, commands: commands, timeout: kFGSocketReadTimeout, exactMatch: isExactMatch, delegate: delegate)
    }
    
    
    func start() {
        var err: HubError?
        if !reachability.isReachable {
            err = HubError.NoConnection
            Log.error(err!.description)
        }
        if self.socket == nil {
            err = HubError.InvalidParameter
            Log.error(err!.description)
        }
        if err == nil {
            self.setupFailTimer()
            self.observerIds.removeAll()
            for i in 0..<self.commands.count {
                let c: FGCommand? = self.commands[i]
                let obsvId: String = self.setupObserver(for: c!, index: i)
                if obsvId != "" {
                    self.observerIds.append(obsvId)
                }
            }
            if self.delegate!.responds(to: #selector(self.delegate?.listenerDidStart(_:))) {
                self.delegate?.listenerDidStart(self)
            }
        }
        else {
            if self.delegate!.responds(to: #selector(FGCommandListenerDelegate.listener(_:foundMatchedIdx:receivedCommand:orStoppedWithError:))) {
                self.delegate?.listener(self, foundMatchedIdx: NSNotFound, receivedCommand: nil, orStoppedWithError: err)
            }
        }
    }
    
    /** Stop listening. */
    
    func stop() {
        self.internalStop()
        let desc: String = "wait manually stopped: \(self.commands)"
        Log.info("%@", desc)
        //    if ([self.delegate respondsToSelector:@selector(listener:foundMatchedIdx:receivedCommand:orStoppedWithError:)]) {
        //        NSError *err = [NSError FingiErrorWithCode:FG_ErrorCode_Cancelled
        //                                       description:desc];
        //        [self.delegate listener:self foundMatchedIdx:NSNotFound receivedCommand:nil orStoppedWithError:err];
        //    }
    }
    
    func internalStop() {
        if (self.failTimer?.isValid)! {
            for iden in self.observerIds {
               // self.bk_removeObservers(withIdentifier: iden)
            }
            self.failTimer?.invalidate()
            self.failTimer = nil
        }
    }
    // MARK: - internal
    
    func setupFailTimer() {
        // fail case: timeout
        if self.timeout <= 0 {
            self.timeout = kFGSocketReadTimeout
        }
        // timeout cannot be 0 or less
        self.failTimer = Timer.bk_timer(with: self.timeout, block: {(_ timer: Timer) -> Void in
            let desc: String = "wait timed out: \(self.commands)"
            self.Log.warning("%@", desc)
            let err = HubError.RequestTimeout
            self.Log.error(err.description)
            self.stop()
        }, repeats: false)
        RunLoop.current.add(self.failTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func stop(withMatchedCommand cmd: FGCommand, index idx: Int) {
        self.internalStop()
        if (self.delegate?.responds(to: #selector(FGCommandListenerDelegate.listener(_:foundMatchedIdx:receivedCommand:orStoppedWithError:))))! {
            self.delegate?.listener(self, foundMatchedIdx: idx, receivedCommand: cmd, orStoppedWithError: nil)
        }
    }
    
    // MARK: - FGCommand level
    var keyNew: String = "new"
    var keyLastCommand: String = "lastCommand"
    var keyLastCommandRead: String = "lastCommandRead"
    
    func setupObserver(for c: FGCommand, index idx: Int) -> String {
        let shouldLog: Bool = self.socket!.shouldLogCommand(c)
        if shouldLog {
            Log.debug("waiting: %@", c.plainString)
        }
        weak var weakSelf = self
        let obsvId: String = ProcessInfo.processInfo.globallyUniqueString
        /*self.socket.bk_addObserver(forKeyPath: keyLastCommandRead, identifier: obsvId, options: NSKeyValueObservingOptionNew, task: {(_ obj: Any, _ change: [AnyHashable: Any]) -> Void in
            // obj is method receiver
            var m: FGCommand? = (change[NSKeyValueChangeNewKey] as? String)
            var match: Bool = false
            if m != nil {
                if weakSelf?.exactMatch {
                    if m?.isEqual(c) {
                        match = true
                    }
                }
                else {
                    if m?.isContaining(c) {
                        match = true
                    }
                }
            }
            // success
            if match {
                var desc: String = "wait success: \(c.plainString)"
                if shouldLog {
                    weakSelf?.logVerbose(desc)
                }
                weakSelf?.stop(withMatchedCommand: m, index: idx)
            }
        })*/
        return obsvId
    }
    
    func logWarn(_ string: String) {
        Log.warning("%@", string)
    }
    
    func logVerbose(_ string: String) {
        Log.debug("%@", string)
    }
}
