//
//  FGConversation.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

import Foundation
let FGConversation_INVALID_ID = NSIntegerMax

class FGConversation: NSObject {
    /** Conversation ID, invalid value is FGConversation_INVALID_ID */
    var identifier: Int = 0
    /** Conversation subject */
    var subject: String = ""
    /** The room number this conversation belongs to. */
    var roomNo: Int = 0
    /** The mailbox ID. */
    var mailboxId: Int = 0
    /** The time it is created. */
    var createdAt: Date!
    /** Conversation is replyable, default is YES. */
    var isReplyable: Bool = true
    /** Conversation is hidden, default is NO. */
    var isHidden: Bool = false
    /** FGMessage objects. The conversation massages. Automatically sorted by `identifier` when set. */
    var messages = [Any]()
    /** If YES, a request for this object has been sent and is waiting for a response.
     For use in table view to show activity indicator when deleting conversation. Default is NO. */
    var isWaiting: Bool = false
    /** Initializes a new object */
    
    override init() {
        super.init()
        
        self.isReplyable = true
        self.isHidden = false
        self.identifier = FGConversation_INVALID_ID
        
    }
    
    convenience init(dictionary dict: [AnyHashable: Any]) {
        self.init()
        
        self.isWaiting = false
        self.identifier = Int(dict["id"] as! NSNumber)
        self.subject = dict["subject"] as! String
        self.roomNo = Int(dict["room_number"]  as! NSNumber)
        self.mailboxId = Int(dict["postbox_id"] as! NSNumber)
        self.createdAt = Date.fromRFC3339String(string: dict["created_at"] as! String)
        self.isReplyable = dict["replyable"] as! Bool
        self.isHidden = dict["hidden"] as! Bool
        self.messages = FGMessage().objects(fromArrayOfDictionaries: dict["messages"] as! [Any])
        
    }
    
    /*func setMessages(_ messages: [Any]) {
        messages = messages.filteredArrayForKind(ofClass: FGMessage.self)
        // WARNING: messages may come at same second, so sorting by createAt date won't work!
        // sort by ID instead
        var sd: [Any] = [NSSortDescriptor(key: "identifier", ascending: true)]
        self.messages = (messages as NSArray).sortedArray(using: sd)
        //    // no sorting
        //    _messages = messages;
        for msg: FGMessage in self.messages {
            msg.conversation = self
        }
    }
    
    class func conversations(fromArrayOfDictionaries array: [Any]) -> [Any] {
        var m: [Any]
        if array.toNSArray().count {
            m = [Any]()
            array = array.filteredArrayForKind(ofClass: [AnyHashable: Any].self)
            for d: [AnyHashable: Any] in array {
                var msg: FGConversation? = d
                if msg != nil {
                    m.append(msg)
                }
            }
        }
        return [Any](arrayLiteral: m)
    }
    
    class func unreadMessages(inConversations conversations: [Any]) -> Int {
        var count: Int = 0
        for c: FGConversation in conversations {
            for m: FGMessage in c.messages {
                if m.status == FGMessageStatusUnread {
                    count += 1
                }
            }
        }
        return count
    }
    
    func earliestMessage() -> FGMessage {
        return self.messages.count > 0 ? self.messages[0] : nil
    }
    
    func latestMessage() -> FGMessage {
        return self.messages.count > 0 ? self.messages.last! : nil
    }
    
    func message(withID identifier: Int) -> FGMessage {
        for m: FGMessage in self.messages {
            if m.identifier == identifier {
                return m
            }
        }
        return nil
    }
    
    func messages(withStatus statuses: Int) -> [Any] {
        var p = NSPredicate(block: {(_ evaluatedObject: Any, _ bindings: [AnyHashable: Any]) -> BOOL in
            if (evaluatedObject is FGMessage) {
                var m: FGMessage? = (evaluatedObject as? FGMessage)
                if (m?.status & statuses) != 0 {
                    return true
                }
            }
            return false
        })
        return self.messages.filtered(using: p)
    }
    
    override func description() -> String {
        return "[<\(NSStringFromClass(self.self))> id:\(UInt(self.identifier)) subject:\(self.subject) messages:\(UInt(self.messages.count))]"
    }*/
}
