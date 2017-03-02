//
//  FGMessage.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

import Foundation
let FGMessage_INVALID_ID = NSIntegerMax
// use bit shift to easily compare multiple statuses at once

enum FGMessageStatus : Int {
    case unread
    case readOrSelfCreated
    
    /*static let unread: FGMessageStatus = 1 << 0
    /** unread */
    static let readOrSelfCreated: FGMessageStatus = 1 << 1*/
}
class FGMessage: NSObject {
    
    /** Message ID, invalid value is FGMessage_INVALID_ID */
    var identifier: Int = 0
    /** Message body */
    var body: String = ""
    /** Message status. */
    var status = FGMessageStatus.unread
    /** The time it is created. */
    var createdAt: Date!
    /** Sender's name */
    var senderName: String = ""
    /** Sender's ID */
    var senderUID: String = ""
    /** Receiver's name */
    var messageFor: String = ""
    /** The conversation this message belongs to */
    weak var conversation: FGConversation?
    
    func objects(fromArrayOfDictionaries array: [Any]) -> [Any] {
        var m = [Any]()
        for d in array {
            let obj: FGMessage? = FGMessage(dictionary: d as! [AnyHashable: Any])
            if obj != nil {
                m.append(obj!)
            }
        }
        return [Any](arrayLiteral: m)
    }
    override init(){
        super.init()
    }
    init(dictionary dict: [AnyHashable: Any]) {
        super.init()
        self.identifier = Int(dict["id"] as! NSNumber)
        self.body = dict["body"] as! String
        self.createdAt = Date.fromRFC3339String(string: dict["created_at"] as! String)
        self.senderName = dict["sender_name"] as! String
        self.senderUID = dict["sender_uid"] as! String
        self.messageFor = dict["message_for"] as! String
        let isRead: Bool = dict["is_read"] as! Bool
        self.status = self.status(fromIsRead: isRead, senderUID: self.senderUID)
    }
    
    func status(fromIsRead b: Bool, senderUID uid: String) -> FGMessageStatus {
        if (uid == FGSession.sharedInstance.UDID as String) {
            return .readOrSelfCreated
        }
        else {
            return b ? .readOrSelfCreated : .unread
        }
    }
    
    func string(from status: FGMessageStatus) -> String {
        switch status {
        case .readOrSelfCreated:
            return "read"
        default:
            return "unread"
        }
        
    }
    
    override var description : String {
        return "[<\(NSStringFromClass(FGMessage.self))> id:\(UInt(self.identifier)) sender:\(self.senderUID) status:\((self.status)) body:\(self.body)]"
    }
}
