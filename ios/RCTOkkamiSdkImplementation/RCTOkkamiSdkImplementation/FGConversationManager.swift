//
//  FGConversationManager.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import AudioToolbox


enum FGConversationManagerMode : Int {
    case _PreConnected
    case _Connected
}
class FGConversationManager: NSObject {
    /*/** The auth used for all requests.
     When using -initWithProperty:, you must set this auth at some point to make API requests work.
     When using -initWithRoom:, if this auth is nil, it falls back to room's auth. */
    var auth: FGAuth!
    ///---------------------------
    /// @name post-initializing
    ///---------------------------
    /** Enable/disable conversation polling */
    var isEnableConversationPolling: Bool = false
    /** All conversations. Will be set to nil when the receiver is deallocated. Default is an empty NSMutableArray.
     This property is observed by FGEntityObserver. */
    var conversations = [Any]()
    /** All property mailboxes. Will be set to nil when the receiver is deallocated. Default is an empty NSMutableArray.
     This property is observed by FGEntityObserver. */
    var mailboxes = [Any]()
    /** Save current user selected mailbox id. Default is nil. */
    var userSelectedMailboxId: NSNumber?
    /** User can observe this to display badge number, counting unread messages. Default is 0. */
    var badgeNumber: Int = 0
    var mailboxEntity: FGMailboxEntity?
    var room: FGRoom?
    var entObsv: FGEntityObserver!
    //var roomHubObsv: THObserver!
    var pollTimer: Timer!
    var pollInterval: TimeInterval {
        get {
            // TODO: add getter implementation
        }
        set(pollInterval) {
            //    FGLogWarnWithClsAndFuncName("using debug poll interval!");
            //    _pollInterval = 7.0;
            //    return;
            if pollInterval > 0.0 {
                self.pollInterval = pollInterval
            }
            else {
                //FGLogWarnWithClsAndFuncName("invalid poll interval: %.1f, will use default interval instead: %.1f", pollInterval, self.defaultPollInterval)
                self.pollInterval = self.defaultPollInterval
            }
        }
    }
    var defaultPollInterval = TimeInterval()
    var mode = FGConversationManagerMode(rawValue: 0)
    var getConverConn: NSURLConnection!
    var getMailboxConn: NSURLConnection!
    
    
    convenience init(mailboxEntity: FGMailboxEntity) {
        self.init()
        
        assert((mailboxEntity is FGMailboxEntity), "entity is invalid (got \(mailboxEntity))")
        self.mode = ._PreConnected
        self.mailboxEntity = mailboxEntity
        self.entObsv = FGEntityObserver(delegate: self)
        self.badgeNumber = 0
        
    }
    
    convenience init(room: FGRoom) {
        self.init()
        self.mode = ._Connected
        self.room = room
        self.entObsv = FGEntityObserver(delegate: self)
        self.badgeNumber = 0
        
    }
    
    override init() {
        super.init()
        
        self.defaultPollInterval = 15.0
        self.pollInterval = self.defaultPollInterval
        self.conversations = [Any]()
        self.mailboxes = [Any]()
        
    }
    
    func setAuth(_ auth: FGAuth) {
        self.auth = auth
    }
    
    deinit {
        // trigger conversations observer before dealloc
        self.conversations = nil
        self.mailboxes = nil
        NotificationCenter.default.removeObserver(self, name: kFGReachabilityChangedNotification, object: self)
    }
    // add a fall back to room's property
    
    func entityOrPropertyOfRoom() -> FGMailboxEntity {
        if self.mailboxEntity {
            return self.mailboxEntity
        }
        else {
            return self.room.property
        }
    }
    // Returns property or room, which ever is not nil. There can only be one nil at the same time.
    
    func entityOrRoom() -> FGEntity {
        if self.mailboxEntity {
            return self.mailboxEntity
        }
        else {
            // this is ok
            return self.room
        }
    }
    
    func setPollInterval(_ pollInterval: TimeInterval) {
        //    FGLogWarnWithClsAndFuncName("using debug poll interval!");
        //    _pollInterval = 7.0;
        //    return;
        if pollInterval > 0.0 {
            self.pollInterval = pollInterval
        }
        else {
            FGLogWarnWithClsAndFuncName("invalid poll interval: %.1f, will use default interval instead: %.1f", pollInterval, self.defaultPollInterval)
            self.pollInterval = self.defaultPollInterval
        }
    }
    // MARK: - FGEntityObserver
    // NOTE: Because FGConversationManager still exists even after selectedEntity is changed.
    // Make sure to carefully check first if the observed entity is actually the selected entity.
    
    func entityObserver(_ obsv: FGEntityObserver, didChangeSelectedEntityPresets presets: FGPresets, dataManager dm: FGDataManager) {
        // see NOTE
        if obsv.entity != self.entityOrRoom() {
            return
        }
        if self.mode == ._PreConnected {
            var t: TimeInterval = CDouble(presets.messagePollTime)
            self.pollInterval = t
        }
    }
    
    func entityObserver(_ obsv: FGEntityObserver, didChangeSelectedEntityRoomState room: FGRoom) {
        // see NOTE
        if obsv.entity != self.entityOrRoom() {
            return
        }
        if self.mode == ._Connected {
            if room.isInConnectedStates {
                // observe hub command when room is connected
                self.auth = room.auth
                weak var weakSelf = self
                self.roomHubObsv = room.hub.onCommands(FGCommand(array: ["UPDATE", FGSession.shared().udid, "MESSAGES"]), callback: {(_ msg: FGCommand) -> Void in
                    weakSelf?.getConversationsWithCallback(nil, playSoundIfNewMessage: true)
                })
            }
            else if room.isInDisconnectedStates {
                self.auth = nil
                self.removeAllConversationsAndMailboxes()
                self.roomHubObsv.stopObserving()
                self.roomHubObsv = nil
            }
        }
    }
    
    func removeAllConversationsAndMailboxes() {
        self.willChangeValue(forKey: "conversations")
        self.conversations.removeAll()
        self.didChangeValue(forKey: "conversations")
        self.willChangeValue(forKey: "mailboxes")
        self.mailboxes.removeAll()
        self.didChangeValue(forKey: "mailboxes")
    }
    
    static let ONE_YEAR: TimeInterval = 31536000.0
    // because DBL_MAX is too much :P
    
    func setEnableConversationPolling(_ enableConversationPolling: Bool) {
        self.enableConversationPolling = enableConversationPolling
        // stop
        self.pollTimer.invalidate()
        self.pollTimer = nil
        // start
        if enableConversationPolling {
            self.schedulePollConversation(in: self.pollInterval)
        }
    }
    // pause polling (set it to ONE_YEAR !!!)
    
    func pauseConversationPollingIfNeeded() {
        if self.isEnableConversationPolling {
            self.schedulePollConversation(in: ONE_YEAR)
        }
    }
    // reset poll time
    
    func restartConversationPollingTimeIfNeeded() {
        if self.isEnableConversationPolling {
            self.schedulePollConversation(in: self.pollInterval)
        }
    }
    
    func schedulePollConversation(in sec: TimeInterval) {
        if sec == ONE_YEAR {
            FGLogVerboseWithClsAndFuncName("PAUSED")
        }
        else {
            FGLogVerboseWithClsAndFuncName("%.1f sec", sec)
        }
        self.pollTimer.invalidate()
        self.pollTimer = Timer.scheduledTimer(timeInterval: sec, target: self, selector: #selector(self.doPollConversation), userInfo: ["interval": Int(sec)], repeats: false)
    }

    func doPollConversation(_ timer: Timer) {
        var sec: TimeInterval? = CDouble((timer.userInfo?.toNSDictionary()?["interval"] as? String)?.toNSNumber())
        weak var weakSelf = self
        self.getConversationsWithCallback({(_ arr: [Any], _ err: Error) -> Void in
            if err {
                // if failed, apply exponential timeout
                FGLogErrorWithClsAndFuncName("poll failed with error %@, applying exponential timeout", err)
                weakSelf?.schedulePollConversation(in: sec * 2)
            }
            else {
                // if success, poll again with initial interval
                FGLogVerboseWithClsAndFuncName("poll success")
                weakSelf?.schedulePollConversation(in: self.pollInterval)
            }
        }, playSoundIfNewMessage: true)
    }
    // MARK: -
    // sort by identifier, descending
    
    func addConversation(inSortedOrder conver: FGConversation) {
        if conver == nil {
            //FGLogWarnWithClsAndFuncName("conver is nil")
            return
        }
        self.conversations.append(conver)
        var sd: [Any] = [NSSortDescriptor(key: "identifier", ascending: false)]
        NSMutableArray(array: self.conversations).sortUsingDescriptors(sd)
    }
    
    func filteredMailbox(_ boxes: [Any], with type: FGMailboxEntityType) -> [Any] {
        var p = NSPredicate(format: "entityType == %d", type)
        return boxes.filtered(using: p)
    }
    
    func getEntityMailboxes(withCallback block: FGArrayBlock) -> NSURLConnection {
        weak var weakSelf = self
        getMailboxConn = FGHTTP.shared().getMailboxesOfEntity(self.entityOrPropertyOfRoom, callback: {(_ arr: [Any], _ err: Error) -> Void in
            if !err {
                var filtered: [Any] = self.filteredMailbox(arr, withEntityType: FGMailboxEntityType_Property)
                weakSelf?.willChangeValue(forKey: "mailboxes")
                weakSelf?.mailboxes?.replaceObjects(in: NSRange(location: 0, length: weakSelf?.mailboxes?.count), withObjectsFrom: filtered)
                weakSelf?.didChangeValue(forKey: "mailboxes")
            }
            BLOCK_SAFE_RUN(block, arr, err)
        })
        return getMailboxConn
    }
    
    func getConversationsWithCallback(_ block: FGArrayBlock) -> NSURLConnection {
        return self.getConversationsWithCallback(block, playSoundIfNewMessage: false)
    }
    func getConversationsWithCallback(_ block: FGArrayBlock, playSoundIfNewMessage playSound: Bool) -> NSURLConnection {
        weak var weakSelf = self
        var auth: FGAuth? = self.auth
        if auth == nil && self.mode == ._Connected {
            // Sometimes during selectedEntity change auth is not yet properly setup.
            // In this case we fall back to room's auth.
            auth = self.room.auth
        }
        getConverConn = FGHTTP.shared().getConversationsUsing(auth, entity: self.entityOrPropertyOfRoom, callback: {(_ arr: [Any], _ err: Error) -> Void in
            weakSelf?.willChangeValue(forKey: "conversations")
            if !err {
                if playSound && self.newMessageExists(in: arr) {
                    // This does NOT work on simulator.
                    // 1002 = Voicemail.caf = standard 3-ding ascending pitch sound
                    AudioServicesPlaySystemSound(1002)
                }
                weakSelf?.conversations?.replaceObjects(in: NSRange(location: 0, length: weakSelf?.conversations?.count), withObjectsFrom: arr)
            }
            weakSelf?.didChangeValue(forKey: "conversations")
            BLOCK_SAFE_RUN(block, arr, err)
        })
        return getConverConn
    }
    // compare new conversations with existing conversations, returns YES if there is a new message.
    // compare new conversations with existing conversations, returns YES if there is a new message.
    
    func newMessageExists(in newConversations: [Any]) -> Bool {
        for newC: FGConversation in newConversations {
            var oldC: FGConversation? = self.conversation(withID: newC.identifier)
            if oldC == nil {
                // new conver
                return true
            }
            for newM: FGMessage in newC.messages {
                var oldM: FGMessage? = oldC?.message(withID: newM.identifier)
                if oldM == nil {
                    // new message
                    return true
                }
            }
        }
        return false
    }
    func startConversation(withBody body: String, to mailbox: FGMailbox, callback block: @escaping (_ conver: FGConversation, _ err: Error) -> Void) -> NSURLConnection {
        weak var weakSelf = self
        return FGHTTP.shared().postMessage(using: self.auth, entity: self.entityOrPropertyOfRoom, body: body, to: mailbox, toConversation: nil, autoReplyMailboxId: nil, autoReplyBody: nil, replyable: true, hidden: false, callback: {(_ obj: FGConversation, _ err: Error) -> Void in
            if err == nil {
                weakSelf?.willChangeValue(forKey: "conversations")
                weakSelf?.addConversation(inSortedOrder: obj)
                // make new conversation appear immediately
                weakSelf?.didChangeValue(forKey: "conversations")
            }
            BLOCK_SAFE_RUN(block, obj, err)
        })!
    }
    func startConversation(withBody body: String, to mailbox: FGMailbox, autoReplyBody autoReply: String, autoReplyMailboxId replyMailboxId: NSNumber, callback block: @escaping (_ conver: FGConversation, _ err: Error) -> Void) -> NSURLConnection {
        weak var weakSelf = self
        return FGHTTP.shared().postMessage(using: self.auth, entity: self.entityOrPropertyOfRoom, body: body, to: mailbox, toConversation: nil, autoReplyMailboxId: replyMailboxId, autoReplyBody: autoReply, replyable: true, hidden: false, callback: {(_ obj: FGConversation, _ err: Error) -> Void in
            if err == nil {
                weakSelf?.willChangeValue(forKey: "conversations")
                weakSelf?.addConversation(inSortedOrder: obj)
                // make new conversation appear immediately
                weakSelf?.didChangeValue(forKey: "conversations")
            }
            BLOCK_SAFE_RUN(block, obj, err)
        })!
    }
    func sendMessageBody(_ body: String, to conver: FGConversation, callback block: @escaping (_ conver: FGConversation, _ err: Error) -> Void) -> NSURLConnection {
        weak var weakSelf = self
        return FGHTTP.shared().postMessage(using: self.auth, entity: self.entityOrPropertyOfRoom, body: body, toMailbox: nil, to: conver, autoReplyMailboxId: nil, autoReplyBody: nil, replyable: (conver) ? conver.replyable : true, hidden: (conver) ? conver.isHidden : false, callback: {(_ obj: FGConversation, _ err: Error) -> Void in
            if err == nil {
                // update local conversation
                var local: FGConversation? = weakSelf?.conversation(withID: obj.identifier)
                var localIdx: Int? = (weakSelf?.conversations? as NSArray).index(of: local)
                weakSelf?.willChangeValue(forKey: "conversations")
                if localIdx == NSNotFound {
                    weakSelf?.addConversation(inSortedOrder: obj)
                    // make new conversation appear immediately
                }
                else {
                    weakSelf?.conversations?[localIdx] = obj
                }
                weakSelf?.didChangeValue(forKey: "conversations")
            }
            BLOCK_SAFE_RUN(block, obj, err)
        })!
    }
    
    func markMessages(_ msgs: [Any], as newStatus: FGMessageStatus, callback block: FGBoolBlock) -> NSURLConnection {
        // only pick messages whose status are NOT newStatus
        var msgsWithDifferentStatus = [Any]()
        for msg: FGMessage in msgs {
            if msg.status != newStatus {
                msgsWithDifferentStatus.append(msg)
            }
        }
        // return if no change
        if msgsWithDifferentStatus.count == 0 {
            BLOCK_SAFE_RUN(block, true, nil)
            return nil
        }
        weak var weakSelf = self
        return FGHTTP.shared().postMessageStatus(using: self.auth, entity: self.entityOrPropertyOfRoom, messages: msgsWithDifferentStatus, status: newStatus, callback: {(_ success: Bool, _ err: Error) -> Void in
            if success {
                weakSelf?.willChangeValue(forKey: "conversations")
                for m: FGMessage in msgsWithDifferentStatus {
                    m.status = newStatus
                }
                weakSelf?.didChangeValue(forKey: "conversations")
            }
            BLOCK_SAFE_RUN(block, success, err)
        })!
    }
    
    func delete(_ conver: FGConversation, callback block: FGBoolBlock) -> NSURLConnection {
        conver.isWaiting = true
        weak var weakSelf = self
        return FGHTTP.shared().deleteConversation(using: self.auth, entity: self.entityOrPropertyOfRoom, conversation: conver, callback: {(_ success: Bool, _ err: Error) -> Void in
            if success {
                // delete locally to update conversations right away
                weakSelf?.willChangeValue(forKey: "conversations")
                weakSelf?.conversations?.remove(at: weakSelf?.conversations?.index(of: conver) ?? -1)
                weakSelf?.didChangeValue(forKey: "conversations")
            }
            conver.isWaiting = false
            BLOCK_SAFE_RUN(block, success, err)
        })
    }
    
    func conversation(withID identifier: Int) -> FGConversation {
        for c: FGConversation in self.conversations {
            if c.identifier == identifier {
                return c
            }
        }
        return nil
    }
    
    func mailbox(withIdentifier identifier: Int) -> FGMailbox {
        for m: FGMailbox in self.mailboxes {
            if m.identifier.isEqual(Int(identifier)) {
                return m
            }
        }
        return nil
    }*/
}
