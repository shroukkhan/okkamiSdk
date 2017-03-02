//
//  FGMailboxEntity.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/21/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGMailboxEntity : FGEntity {
    
    /** Mailboxes. Its object will be an array of FGMailbox objects. */
    var mailboxesDM: FGDataManager?
    
    var conversationManager: FGConversationManager! {
        get{
            if self.conversationManager == nil {
                //FGLogWarnWithClsAndFuncName("not available, call requestConversationManagerWithCallback first!")
            }
            return self.conversationManager
        }set{
            self.conversationManager = newValue
        }
        
    }
    var connReloadRoomInfo: NSURLConnection!
    var connConnect: NSURLConnection!
    var connDisconnect: NSURLConnection!
    
    
    convenience required init(identifier: NSString) {
        self.init()
        self.identifier = identifier.description as NSString?
        self.conversationManager = FGConversationManager()
    }
    
    override var allDataManagers : [Any]? {
        get{
            if self.mailboxesDM == nil {
                self.mailboxesDM = FGDataManager(delegate: self as! FGDataManagerDelegate)
            }
            // must include super objects!
            let new : [Any] = [super.allDataManagers!, self.mailboxesDM!]
            return new
        }
        set{
            self.allDataManagers = newValue
        }
    }
    
    /*override func dataManagerStartLoading(_ dm: FGDataManager) -> NSURLConnection {
        if dm == self.mailboxesDM {
            return FGHTTP.sharedInstance.getMailboxesOf(self, callback: {(_ arr: [Any], _ err: Error) -> Void in
                if !err {
                    dm.object = arr
                }
                dm.error = err
            })
        }
        else {
            // must call super at the end!
            return super.dataManagerStartLoading(dm)
        }
    }*/
    
    /*func requestConversationManagerAuth(withCallback block: @escaping (_ manager: FGConversationManager, _ err: Error) -> Void) {
        weak var weakSelf = self
        FGSession.sharedInstance.requestPreconnectInfoIfNeeded(withCallback: {(_ guestDevice: FGPreconnect, _ err: Error) -> Void in
            if err {
                BLOCK_SAFE_RUN(block, nil, err)
            }
            else {
                weakSelf?.conversationManager?.auth = guestDevice.auth
                BLOCK_SAFE_RUN(block, weakSelf?.conversationManager, nil)
            }
        })
    }*/
    
    func mailbox(withIdentifier identifier: Int) -> FGMailbox? {
        for m in (self.mailboxesDM?.object as! [FGMailbox]) {
            if m.identifier.isEqual(Int(identifier)) {
                return m
            }
        }
        return nil
    }
}
