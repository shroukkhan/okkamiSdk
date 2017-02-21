//
//  FGDataManager.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit
import Foundation
enum FGDMState : Int {
    /** Request loading is not yet started. FGDataManager objects' default state. */
    case stoppedAndNeverStarted = 0
    /** Request is now loading. */
    case loading = 1
    /** Request is canceled. */
    case cancelled = 2
    /** Request stopped. */
    case stopped = 3
}

@objc protocol FGDataManagerDelegate: NSObjectProtocol {
    /** This is where you start your request(s).
     @param dm The data manager that starts loading.
     @return A connection to be kept in data manager (for canceling request, etc.). If nil, state will NOT change to FGDMStateLoading. */
    func dataManagerStartLoading(_ dm: FGDataManager) -> NSURLConnection
}
class FGDataManager: NSObject {
    var autoRefreshDuration: Int?{
        get{
            return self.autoRefreshDuration
        }set{
            self.autoRefreshDuration = newValue
        }
    }
    /** Determines if the receiver is in suspended mode or not. If YES, the NSTimer that runs the
     autorefreshing is invalidated. If NO, thatt NSTimer is recreated.
     Mainly to suspend unnecessary data loading of deselected entity. */
    private var _isSuspendAutoRefreshing : Bool = false
    var isSuspendAutoRefreshing: Bool {
        get{
            return _isSuspendAutoRefreshing
        }set{
            _isSuspendAutoRefreshing = newValue
            if _isSuspendAutoRefreshing {
                self.doCreateAutoRefreshTimer(withDuration: 0)
            }
            else {
                self.doCreateAutoRefreshTimer(withDuration: self.autoRefreshDuration!)
            }
        }
    }
    /** The delegate */
    weak var delegate: FGDataManagerDelegate?
    /** The tag. For debugging. */
    var tag: Int = 0
    
    /** The requested data object. It can be an object, array, or dictionary. */
    var object: Any!
    /** Connection that loads the object. */
    var connection: NSURLConnection!
    /** Holds the error object, if any, when the request stopped.
     Setting this will change receiver's state to FGDMStateStopped. */
    var error: Error?{
        get{
            return self.error
        }set{
            self.error = newValue
            // delay state setting because someone may want to update data by observing this state but data is not there yet
            let delayInSeconds: Double = 0.01
            weak var weakSelf = self
            let popTime = DispatchTime.now() + Double(delayInSeconds * Double(NSEC_PER_SEC))
            //var dead = popTime / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime, execute: {(_: Void) -> Void in
                weakSelf?.state = .stopped
                weakSelf?.connection = nil
            })
        }
    }
    /** Current state. */
    var state : FGDMState?{
        get{
            return self.state
        }set{
            self.state = newValue
        }
    }
    /** Instantiates a new object */
    var autoRefreshTimer: Timer?
    var startLoadingLastFire: Date!
    
    override init() {
        super.init()
        self.state = FGDMState.stoppedAndNeverStarted
    }
    
    convenience init(delegate: FGDataManagerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    deinit {
    }
    
    
    func doCreateAutoRefreshTimer(withDuration duration: Int) {
        self.autoRefreshTimer?.invalidate()
        self.autoRefreshTimer = nil
        weak var weakSelf = self
        if duration > 0 {
            self.autoRefreshTimer = Timer.bk_scheduledTimer(with: TimeInterval(duration), block: { (Timer) in
                weakSelf?.startLoading()
            }, repeats: true) as? Timer
            self.autoRefreshTimer?.tolerance = 10
        }
    }
    
    
    func startLoading() -> NSURLConnection {
        self.cancelLoading()
        self.startLoadingLastFire = Date()
        if self.delegate!.responds(to: #selector(FGDataManagerDelegate.dataManagerStartLoading(_:))) {
            self.connection = self.delegate?.dataManagerStartLoading(self)
            if (self.connection != nil) {
                self.state = FGDMState.loading
            }
        }
        return self.connection
    }
    
    func startLoadingIfNever() -> NSURLConnection {
        if self.state == FGDMState.stoppedAndNeverStarted {
            return self.startLoading()
        }
        return self.connection
    }
    
    func cancelLoading() {
        if self.state == FGDMState.loading {
            self.connection.cancel()
            self.state = FGDMState.cancelled
        }
    }
    
    func reset() {
        self.cancelLoading()
        self.object = nil
        self.error = nil
        self.connection = nil
        self.isSuspendAutoRefreshing = true
        // invalidates `self.autoRefreshTimer`
        self.state = FGDMState.stoppedAndNeverStarted
    }
}
