//
//  FGRoom.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/9/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


enum FGRoomState : Int {
    // ------ Disconnected States ------
    // Any connected room UIs should be dismissed in these states. Enum range [0,9].
    /** Disconnected. */
    case disconnected = 0
    /** Disconnected after trying to connect but failed. */
    case disconnectedBecauseConnectFailed = 2
    /** Disconnected by CORE because guest's room is moved. */
    case disconnectedByRoomMove = 3
    /** Disconnected by CORE because guest is checked-out. */
    case disconnectedByCheckOut = 4
    // ------ Intermediate States ------
    // All app UIs should stay as they are in these states. Enum range [10,19].
    /** User manually connect. */
    case connecting = 10
    /** Hub Reconnecting, usually after internet connection lost or woke up from background. */
    case hubReconnecting = 11
    /** Hub Reconnect failed, will retry when appropriate (e.g. when internet connection is back). */
    case hubReconnectFailedAndShouldRetry = 12
    /** User manually disconnecting. */
    case disconnecting = 13
    // ------ Connected States ------
    // All room UIs should be fully functional in these states. Enum range [20,29].
    /** Room is connected */
    case connected = 20
    /** Room is reconnected after a failed hub connection */
    case hubReconnected = 21
    // ------ Unknown State ------
    // Currently not being used.
    case unknown = 255
    
    
}

class FGRoom: FGEntity {
    
    var hub: FGSocket!
    // -- Room Connected --
    // variables below are set when room is in connected states.
    /** Room Number */
    var number: String?
    /** Name of the person who the room is reserved under */
    var reservationName: String?
    /** Last name of the person who the room is reserved under */
    var lastName: String?
    /** FGDeviceGroup objects representing ALL groups in the room, sorted by name in ascending order. */
    var allGroups = [FGDeviceGroup]()
    /** FGDeviceGroup objects representing groups that has guest's phone uid,
     sorted by name in ascending order. There could be more than one group. */
    var guestDeviceGroups = [FGDeviceGroup]()
    /** FGDevice objects, sorted by uid in ascending order. */
    var allDevices = [FGDevice]()
    /** Room conversation manager. This is automatically created/removed when room is connected/disconnected, respectively. */
    var conversationManager: FGConversationManager!
    /** Shopping cart manager. This is nil by default. */
    var shoppingCartManager: FGShoppingCartManager!
    /** Spa reservation manager. This is nil by default. */
    var spaReservationManager: FGSpaReservationManager!
    /** The folio is the object that manages items charged to a room */
    //ar folio: FGFolio!
    
    /** Room state */
    var state = FGRoomState(rawValue: 0)
    
    var connReloadRoomInfo: NSURLConnection!
    var connConnect: NSURLConnection!
    var connDisconnect: NSURLConnection!
    var observers = [Any]()
    var didDisconnectBlock = FGVoidBlock.self
    var loadGenresBlock = FGErrorBlock.self
    var didLoginBlock: Any!
    var didLoginObserver: Any!
    var hubDisconnected: Bool = false
    var coreDisconnected: Bool = false
    
    /** parent entity. */
    var parent : FGEntity?{
        get{
            return self.property
        }
    }
    
    /** Room conversation manager. This is automatically created/removed when room is connected/disconnected, respectively. */
    //dynamic var conversationManager : FGConversationManager? = nil
    
    /** Shopping cart manager. This is nil by default. */
    //dynamic var shoppingCartManager : FGShoppingCartManager? = nil
    
    /** Spa reservation manager. This is nil by default. */
    //dynamic var spaReservationManager : FGSpaReservationManager? = nil
    
    /** The folio is the object that manages items charged to a room */
    //dynamic var folio : FGFolio? = nil
    
    public func getParent() -> FGEntity?{
        return self.property
    }
    
    public func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    convenience required init(connectResp: ConnectRoomResponse) {
        self.init()
        
        let dict : [String:String] = [
        "company_id":connectResp.room!.company_id as String,
        "brand_id":connectResp.room!.brand_id as String,
        "property_id":connectResp.room!.property_id as String,
        "room_id":connectResp.room!.room_id as String,
        "number":connectResp.room!.number as String,
        "presets":connectResp.room!.presetsAsJson as String,
        "groups":connectResp.room!.groupsAsJson as String,
        "checked_in":connectResp.room!.checked_inAsJson as String,
        "frcds":connectResp.room!.frcdsAsJson as String
        ]
        self.connectWithObject(connect: FGConnect(nameRoom: connectResp.roomName, roomToken: connectResp.roomToken, rooms_id: connectResp.room!.room_id))
        self.room = FGRoom(identifier: connectResp.room!.room_id)
        self.property = FGProperty(identifier: connectResp.room!.property_id)
        self.brand = FGBrand(identifier: connectResp.room!.brand_id)
        self.company = FGCompany(identifier: connectResp.room!.company_id)
        self.auth = FGDeviceAuth(token: connectResp.auth!.token, secret: connectResp.auth!.secret)
        self.mergeWithDictionary(dict: dict)
    }
    convenience required init(identifier: NSString) {
        self.init()
        self.identifier = identifier
    }
    
    convenience required init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.name = dictionary["name"] as! NSString
        self.identifier = dictionary["id"] as? NSString
    }
    
    deinit {
        self.property?.room = nil
    }
    
    func respondToHubReloadCommand() {
        /*if self.isInConnectedStates() {
            weak var weakSelf = (self)
            self.connReloadRoomInfo.cancel()
            self.connReloadRoomInfo = FGHTTP.sharedInstance.getRoomInfo(self, callback: {(_ dict: [AnyHashable: Any], _ err: Error) -> Void in
                // create a new room for device comparison
                var newRoom = FGRoom(identifier: 0)
                if !(try? newRoom.mergeDeviceAndPresets(fromDictionary: dict)) {
                    FGLogErrorWithClsAndFuncName("[ERROR] bad room data %@", err.localizedDescription)
                    return
                }
                if weakSelf?.areNonGuestDevicesEqual(to: newRoom) {
                    // Room has no change, do nothing.
                    FGLogInfoWithClsAndFuncName("no room change from reload, continue session...")
                }
                else {
                    // Room changed. Disconnect and show an alert.
                    var c: FGConnect? = weakSelf.connect
                    weakSelf.disconnect(withCallback: {() -> Void in
                        if FGSession.shared().allowShowingAlertViews {
                            var alert = UIAlertView.bk_init(withTitle: "Room Disconnected", message: "You have checked-out of your room or room information has been updated.")
                            alert.addButton(withTitle: FG_buttonTitle_OK)
                            alert.bk_addButton(withTitle: NSLocalizedString("Reconnect", comment: "alert button"), handler: {() -> Void in
                                weakSelf.connect(withObject: c)
                            })
                            alert.show()
                        }
                    })
                }
            })
        }else{
            //FGLogErrorWithClsAndFuncName(@"you are not connected to room");
        }*/
    }
    
    func isInDisconnectedStates() -> Bool {
        return 0 <= self.state!.rawValue && self.state!.rawValue <= 9
    }
    
    func isInIntermediateStates() -> Bool {
        return 10 <= self.state!.rawValue && self.state!.rawValue <= 19
    }
    
    func isInConnectedStates() -> Bool {
        return 20 <= self.state!.rawValue && self.state!.rawValue <= 29
    }
    
    func isDeviceStillInRoom(withCallback block: FGBoolBlock) {
        /*FGHTTP.sharedInstance.getDeviceRooms(withCallback: {(_ arr: [Any], _ err: Error) -> Void in
            if err {
                BLOCK_SAFE_RUN(block, false, err)
                return
            }
            for roomID: NSNumber in arr {
                if CUnsignedInt(roomID) == self.identifier {
                    BLOCK_SAFE_RUN(block, true, nil)
                    return
                }
            }
            BLOCK_SAFE_RUN(block, false, nil)
        })*/
    }
    
    func setState(_ state: FGRoomState) {
        //FGLogInfoWithClsName("state change -> %@", self.stateName(with: state))
        self.state = state
        if self.isInConnectedStates() {
            self.startRespondingToHub()
            self.queryGuestDeviceGroupDevicesState()
            //self.shoppingCartManager = FGShoppingCartManager(self)
            self.spaReservationManager = FGSpaReservationManager()
            //self.folio = FGFolio()
        }
        else if self.isInDisconnectedStates() {
            self.stopRespondingToHub()
            self.auth = nil
            self.connect = nil
            self.cleanupFlagsAndUI()
            self.shoppingCartManager = nil
            self.spaReservationManager = nil
            //self.folio = nil
        }
        
    }
    
    func stateName(with state: FGRoomState) -> String {
        var name: String
        switch state {
        case .disconnected:
            name = "FGRoomStateDisconnected"
        case .disconnectedBecauseConnectFailed:
            name = "FGRoomStateDisconnectedBecauseConnectFailed"
        case .disconnectedByRoomMove:
            name = "FGRoomStateDisconnectedByRoomMove"
        case .disconnectedByCheckOut:
            name = "FGRoomStateDisconnectedByCheckOut"
        case .connecting:
            name = "FGRoomStateConnecting"
        case .hubReconnecting:
            name = "FGRoomStateHubReconnecting"
        case .hubReconnectFailedAndShouldRetry:
            name = "FGRoomStateHubReconnectFailedAndShouldRetry"
        case .disconnecting:
            name = "FGRoomStateDisconnecting"
        case .connected:
            name = "FGRoomStateConnected"
        case .hubReconnected:
            name = "FGRoomStateHubReconnected"
        default:
            name = "FGRoomStateUnknown"
        }
        
        return name
    }
    
    func cleanupFlagsAndUI() {
        self.connReloadRoomInfo.cancel()
        didLoginBlock = nil
        didLoginObserver = nil
    }
    
    func errorIfNotConnected() -> Error? {
        if !self.isInConnectedStates() {
            //return Error.fingiError(withCode: FG_ErrorCode_NotConnectedToRoom, description: "Room is not connected. (room state is \(Int(self.state)))", recovery: "Room is not connected.")
        }
        return nil
    }
    func reconnectToHubOnly() {
        weak var weakSelf = (self)
        /*var reachable: Bool? = FGReachability.isReachableAndShowAlertIfNo(withRetryHandler: {() -> Void in
            weakSelf?.reconnectToHubOnly()
        })
        if reachable != nil {
            self.connectToHub()
        }*/
    }
    
    func disconnect(withCallback block: FGVoidBlock) {
        self.disconnect(withEnd: .disconnected, callback: block)
    }
    
    func disconnect(withEnd endState: FGRoomState, callback block: FGVoidBlock) {
        //didDisconnectBlock = block
        self.state = FGRoomState.disconnecting
        
        // it's disconnecting, don't set to endState yet...
        coreDisconnected = false
        hubDisconnected = coreDisconnected
        
        weak var weakSelf = (self)
        
        // disconnect hub
        
        /*self.hub.disconnect(withCallback: {(_ err: Error) -> Void in
            self.hubDisconnected = true
            weakSelf?.roomDidDisconnect(withEnd: endState)
        })*/
        
        // disconnect CORE
        self.connDisconnect.cancel()
        /*self.connDisconnect = FGHTTP.sharedInstance.postDisconnect(to: self, callback: {(_ err: Error) -> Void in
            coreDisconnected = true
            weakSelf?.roomDidDisconnect(withEnd: endState)
        })*/
        //FGOpenWaysAPIManager.clearSavedData()
    }
    
    func roomDidDisconnect(withEnd endState: FGRoomState) {
        // called when both CORE and hub are manually disconnected
        if hubDisconnected && coreDisconnected {
            self.state = endState
            self.cleanupFlagsAndUI()
            //BLOCK_SAFE_RUN(didDisconnectBlock)
            //didDisconnectBlock = nil
            // remove SDWebImageManager disk cache
            //var manager = SDWebImageManager.shared
            //manager.imageCache.clearDisk()
        }
    }
    // MARK: connection flow
    
    func connectToHub() {
        if self.state != FGRoomState.connecting {
            self.state = FGRoomState.hubReconnecting
        }
        self.hub = FGSocket()
        //self.hub.room = self
        /*self.hub.connectToHub(withCallback: {(_ err: Error) -> Void in
            if err {
                FGLogErrorWithClsAndFuncName("[ERROR]: %@", err)
                // override error
                err = Error.fingiError(withCode: FG_ErrorCode_RequestFailed, description: nil, recovery: FG_ErrorMsgForDummies_RoomConnectFailed)
                try? self.connectDidFail()
            }
            else {
                FGLogInfoWithClsAndFuncName("[OK]")
                self.identifyToHub()
            }
        })*/
    }
    
    func identifyToHub() {
        /*self.hub.identifyDeviceID(FGSession.sharedInstance.UDID, callback: {(_ err: Error) -> Void in
            if err {
                FGLogErrorWithClsAndFuncName("%@", err.localizedDescription)
                // override error
                err = Error.fingiError(withCode: FG_ErrorCode_RequestFailed, description: nil, recovery: FG_ErrorMsgForDummies_RoomConnectFailed)
                try? self.connectDidFail()
            }
            else {
                FGLogInfoWithClsAndFuncName("[OK]")
                self.didIdentifyToHub()
            }
        })*/
    }
    
    func didIdentifyToHub() {
        self.connectDidSucceed()
        // --------------------
    }
    
    func connectDidFailWithError(_ err: Error?) {
        //try? self.showConnectAlert()
        if self.state == FGRoomState.hubReconnecting {
            self.state = FGRoomState.hubReconnectFailedAndShouldRetry
        }
        else {
            self.state = FGRoomState.disconnectedBecauseConnectFailed
        }
    }
    
    func connectDidSucceed() {
        if self.state == FGRoomState.hubReconnecting {
            self.state = FGRoomState.hubReconnected
        }
        else {
            self.state = FGRoomState.connected
        }
        self.cleanupFlagsAndUI()
    }
    
    // Helps displaying alert for a failed connection.
    // Use err.localizedDescription for alert body. If not exist, use a default one.
    
    func showConnectAlertWithError(_ err: Error?) {
        
    }
    
    override var description: String {
        return "[<\(self)> (\(self)) ID:\(self.identifierString) room number:\(self.number)]"
    }
}

extension FGRoom {
    
    /** Check if room has a FGTV component */
    func hasTV() -> Bool {
        for dGroup: FGDeviceGroup in self.guestDeviceGroups {
            if dGroup.components(with: FGTV.self)?.count != nil {
                return true
            }
        }
        return false
    }
    
    // ==========================================================
    // Guest Device Group Methods
    // ==========================================================
    /** Creates a FGRoom object from a JSON dictionary.
     @param dict NSDictionary object containing room information.
     @returns Success bool
     */
    
    public func mergeWithDictionary(dict : Dictionary<String, Any>){
        self.identifier = dict["room_id"] as! NSString
        self.number = dict["number"] as? String
        var checkedIn = convertToDictionary(text: dict["checked_in"] as! String)
        self.reservationName = checkedIn!["reservation_name"] as? String
        self.lastName = checkedIn!["last_name"] as? String
        var mdDeviceUIDs : Dictionary<String,Any>?
        var allGroupNames : Array<Any>?
        
        var filteredArray = (dict["groups"] as! [Any]).filter() {
            $0 is [String:AnyObject]
        }
        for groupDict in filteredArray {
            var mDevices = [Any]()
            var dicti = groupDict as! Dictionary<String,Any>
            for uid in (dicti["devices"] as! [Any]) {
                mDevices.append(uid as! String)
            }
            allGroupNames?.append(dicti["name"]!)
            mdDeviceUIDs?["\(dicti["name"])"] = mDevices
        }
        
        // create FGGroup and FGDevice
        var mGroups = [Any]()
        var mDevices = [Any]()
        // Create devices
        let filteredArray2 = (dict["devices"] as! [Any]).filter() {
            $0 is [String:AnyObject]
        }
        for deviceDict in filteredArray2 {
            var d = FGDevice(dictionary: deviceDict as! Dictionary<String, Any>)
            d.room = self
            for c: FGComponent in d.components! {
                c.device = d
                c.room = self
            }
            mDevices.append(d)
        }
        self.allDevices = mDevices as! [FGDevice]
        
        let filteredArray3 = (dict["groups"] as! [Any]).filter() {
            $0 is [String:AnyObject]
        }
        filteredArray = filteredArray3
        for groupDict in filteredArray {
            var dicti = groupDict as! Dictionary<String,Any>
            var group = FGDeviceGroup(deviceGroupWithName: dicti["name"] as! NSString, devices: nil)
            for deviceUID in (dicti["devices"] as! [Any]) {
                var d: FGDevice? = self.device(fromUID: deviceUID as! String)
                if d != nil {
                    d?.group = group
                    group.addDevice(devices: d!)
                }
            }
            if ((group.devices?.count) != nil) {
                mGroups.append(group)
            }
        }
        
        self.allGroups = mGroups as! [FGDeviceGroup]
        // no sort
        //self.allGroups = [mGroups sortedArrayUsingDescriptors:sdName]; // sort
        var guestDevices = [Any]()
        var guestDeviceGroupNames = [Any]()
        
        for g: FGDeviceGroup in self.allGroups {
            var hasPhone: Bool = false
            for d: FGDevice in g.devices! {
                if (d.uid == FGSession.sharedInstance.UDID) {
                    // In case CORE requested data is corrupted, avoid duplicate phone appearing in one group,
                    // otherwise duplicate groups will be added and cause nasty bugs.
                    // It should never come to this though.
                    if (guestDevices as NSArray).index(of: g) == NSNotFound {
                        guestDevices.append(g)
                    }
                    hasPhone = true
                }
            }
            if hasPhone {
                guestDeviceGroupNames.append(g.name)
            }
        }
        self.guestDeviceGroups = guestDevices as! [FGDeviceGroup]
        // no sort
        //FGLogInfo("All Groups (%d): %@", allGroupNames.count, (allGroupNames as NSArray).componentsJoined(byString: ", "))
        //FGLogInfo("Guest Device Groups (%d): %@", guestDeviceGroupNames.count, (guestDeviceGroupNames as NSArray).componentsJoined(byString: ", "))
        //self.guestDeviceGroups = [phoneGroupDevices sortedArrayUsingDescriptors:sdName]; // sort
        var dictPreset = dict["presets"] as! Dictionary<String, Any>
        var hubURL: String = dictPreset["hub_dns_name"] as! String
        //dict[@"hub_url"];
        if hubURL.characters.count > 0 {
            //FGLogInfo("Using hub URL: %@", hubURL)
            FGSession.sharedInstance.hubURL = URL(string: hubURL)!
        }
        var hubPort: String = dictPreset["hub_ssl_port"] as! String
        if hubPort.characters.count > 0 {
            //FGLogInfo("Using hub Port: %@", hubPort)
            FGSession.sharedInstance.hubPort = Int(hubPort)!
        }
        
        //var g = dict["groups"] as! [Any]
        
        //read group and its component UIDs
        /*for (key, devices) in g{
         var mDevices : Array<Any>?
         for uid in devices {
         mDevices?.append(uid as! NSString)
         }
         allGroupNames?.append(g["name"])
         mdDeviceUIDs?.updateValue(mDevices, forKey: g["name"] as! String)
         }*/
        
        //create FGGroup and FGDevice
        //var mGroups : Array<Any>?
        //var mDevices: Array<Any>?
        
        /*
         var devices = dict["devices"] as! Dictionary<String,Any>
         for deviceDict in devices{
         //var d : FGDevice = FGDevice(deviceDict)
         }*/
        
    }
    
    public override func connectWithObject(connect: FGConnect) {
        self.connect = connect
        /*
         // verify
         if (![connect isKindOfClass:[FGConnect class]]) return;
         BOOL reachable = [FGReachability isReachableAndShowAlertIfNoWithRetryHandler:^{
         [weakSelf connectWithObject:connect]; // retry
         }];
         if (!reachable) return;
         if (self.isInConnectedStates) return;
         
         // keep track of connect, and add entity line to it
         connect.line = [FGEntityLine lineFromCompanyId:self.property.brand.company.identifier
         brandId:self.property.brand.identifier
         propertyId:self.property.identifier
         error:nil];
         self.connect = connect;
         
         FGLogInfo(@"*** Connecting to propertyID: %@ with name/code: %@/%@", self.property.identifierString, connect.name, connect.code);
         
         [self.connConnect cancel]; // cancel any connection that may exist
         self.state = FGRoomStateConnecting;*/
    }
    
    
    /** Send `QUERY` message. All device should reply automatically.
     This will update their current states. This is automatically sent when
     [FGSession shared].state is FGRoomStateConnected or FGRoomStateHubReconnected).
     */
    
    func queryGuestDeviceGroupDevicesState() {
        //var m = FGCommand(string: "QUERY")
        //self.hub.write(m)
    }
    /** Make all guest device groups' devices and components start responding to hub messages. */
    
    func startRespondingToHub() {
        for g: FGDeviceGroup in self.guestDeviceGroups {
            for d: FGDevice in g.devices! {
                d.addMessageObservers()
                for c: FGComponent in d.components! {
                    c.addMessageObservers()
                }
            }
        }
    }
    /** Make all guest device groups' devices and components stop responding to hub messages. */
    
    func stopRespondingToHub() {
        for g: FGDeviceGroup in self.guestDeviceGroups {
            for d: FGDevice in g.devices! {
                d.removeMessageObservers()
                for c: FGComponent in d.components! {
                    c.removeMessageObservers()
                }
            }
        }
    }
    /** Queries FGComponentBase objects with the same `type` as the given class,
     from **all** room groups.
     @param aClass A FGComponentBase subclass.
     @return FGComponentBase objects.
     */
    
    func allComponents(with aClass: AnyClass) -> [Any]? {
        if !aClass.isSubclass(of: FGComponent.self) {
            return nil
        }
        let classMirror = Mirror(reflecting: aClass)
        let result: [Any] = (self.allComponents() as NSArray).filtered(using: NSPredicate(format: "type == %@", String(describing: classMirror.subjectType)))
        return result.count > 0 ? result : nil
    }
    /** Queries FGDevice objects with the same `type` as the given class,
     from **all** room groups.
     @param aClass A FGDevice subclass.*/
    
    func allDevices(with aClass: AnyClass) -> [Any]? {
        if !aClass.isSubclass(of: FGDevice.self) {
            return nil
        }
        let result: [Any] = (self.allDevices as NSArray).filtered(using: NSPredicate(format: "type == %@", String(describing: aClass.type)))
        return result.count > 0 ? result : nil
    }
    /** Queries FGComponentBase objects in guestDeviceGroups with the same `type` as the given class.
     @param aClass A FGComponentBase subclass.
     @return newly created FGComponentGroup objects.
     */
    
    func guestComponentGroups(withComponentClass aClass: AnyClass) -> [Any]? {
        if !aClass.isSubclass(of: FGComponent.self) {
            return nil
        }
        var newGroups = [Any]()
        for g: FGDeviceGroup in self.guestDeviceGroups {
            var newGroup = FGComponentGroup(componentGroupWithName: g.name, devices: nil)
            for d: FGDevice in g.devices! {
                let filteredComps: [Any] = (d.components! as NSArray).filtered(using: NSPredicate(format: "type == %@", String(describing: aClass.type)))
                if filteredComps.count > 0{
                    newGroup.addComponents(components: filteredComps as NSArray)
                }
            }
            // append newGroup if there is a component in it
            if ((newGroup.components?.count) != nil) {
                newGroups.append(newGroup)
            }
        }
        return newGroups
    }
    /** Queries FGDevice objects in guestDeviceGroups with the same `type` as the given class.
     @param aClass A FGDevice subclass.
     @return newly created FGDeviceGroup objects.
     */
    
    func guestDeviceGroups(withDeviceClass aClass: AnyClass) -> [Any]? {
        if !aClass.isSubclass(of: FGDevice.self) {
            return nil
        }
        var newGroups = [Any]()
        for g: FGDeviceGroup in self.guestDeviceGroups {
            var newGroup = FGDeviceGroup(deviceGroupWithName: g.name, devices: nil)
            for d: FGDevice in g.devices! {
                if (d.type as! String).isEqual(toStringCaseInsensitive: String(describing: aClass.type)) {
                    newGroup.addDevice(devices: d)
                }
            }
            // append newGroup if there is a device in it
            if newGroup.devices?.count != nil {
                newGroups.append(newGroup)
            }
        }
        return newGroups
    }
    /** Wrapper of FGSocket observer to manage THObserver objects lifetime */
    
    func onAnyCommand(withCallback block: FGCommandOnlyBlock) {
        //var observer: THObserver? = self.hub.onAnyCommand(withCallback: block)
        //self.observers.append(observer)
    }
    
    func onCommands(_ cmd: FGCommand, callback block: FGCommandOnlyBlock) {
        //var observer: THObserver? = self.hub.onCommands(cmd, callback: block)
        //self.observers.append(observer)
    }
    
    func onCommandsAction(_ action: String, callback block: FGCommandOnlyBlock) {
        //var observer: THObserver? = self.hub.onCommandsAction(action, callback: block)
        //self.observers.append(observer)
    }
    
    func onCommandsAction(_ action: String, firstArgument arg: String, callback block: FGCommandOnlyBlock) {
        //var observer: THObserver? = self.hub.onCommandsAction(action, firstArgument: arg, callback: block)
        //self.observers.append(observer)
    }
    
    
    func device(fromUID uid: String) -> FGDevice? {
        for d: FGDevice in self.allDevices {
            if ((d.uid as! String) == uid) {
                return d
            }
        }
        return nil
    }
    
    func deviceGroup(fromName name: String) -> FGDeviceGroup? {
        for g: FGDeviceGroup in self.guestDeviceGroups {
            if (g.name as String == name) {
                return g
            }
        }
        return nil
    }
    
    func allComponents() -> [Any] {
        var m = [Any]()
        for d: FGDevice in self.allDevices {
            m.append(d.components!)
        }
        return [Any](arrayLiteral: m)
    }
    
    func allPhoneGroupComponents() -> [Any] {
        var m = [Any]()
        for g: FGDeviceGroup in self.guestDeviceGroups {
            for d: FGDevice in g.devices! {
                m.append(d.components!)
            }
        }
        return [Any](arrayLiteral: m)
    }
    /** Compare non guest devices of two rooms. */
    
    func areNonGuestDevicesEqual(to room: FGRoom) -> Bool {
        if room == nil {
            return false
        }
        if self.guestDeviceGroups.count != room.guestDeviceGroups.count {
            return false
        }
        for i in 0..<self.guestDeviceGroups.count {
            var g: FGDeviceGroup? = self.guestDeviceGroups[i]
            var ag: FGDeviceGroup? = room.guestDeviceGroups[i]
            if !(g?.isNonGuestDevicesEqual(ag!))! {
                return false
            }
        }
        return true
    }
}
