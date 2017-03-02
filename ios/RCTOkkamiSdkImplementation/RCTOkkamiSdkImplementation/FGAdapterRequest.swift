//
//  FGAdapterRequest.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/17/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import UIKit

class FGAdapterRequest: NSObject/*, FGCommandListenerDelegate */{

    var requestIdsToListeners = [AnyHashable: Any]()
    var requestIdsToCallbacks = [AnyHashable: Any]()
    static let FGAdapterRequestCmdAsyncJob: String = "ASYNC_JOB"
    static let FGAdapterRequestTimeout: TimeInterval = 30.0
    
    class func shared() -> FGAdapterRequest {
        var shared: FGAdapterRequest? = nil
        /* TODO: move below code to the static variable initializer (dispatch_once is deprecated) */
        ({() -> Void in
            shared = FGAdapterRequest()
        })()
        return shared!
    }
    
    override init() {
        super.init()
        
        self.requestIdsToListeners = [AnyHashable: Any]()
        self.requestIdsToCallbacks = [AnyHashable: Any]()
        
    }
    /*
    func request(to room: FGRoom, type requestType: String, action requestAction: String, params requestParams: [AnyHashable: Any], callback block: FGObjectBlock) -> NSURLConnection {
        assert((requestType.characters.count ?? 0), "Adapter request type is missing: \(requestType)")
        assert((requestAction.characters.count ?? 0), "Adapter request action is missing: \(requestAction)")
        var path: String = "v3"
        path = URL(fileURLWithPath: path).appendingPathComponent(room.pathComponentWithParents).absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("service_requests").absoluteString
        var params = [AnyHashable: Any]()
        params["request_type"] = requestType
        params["request_action"] = requestAction
        if requestParams.count {
            params["request_params"] = requestParams
        }
        return self.toEntity(room, relativePath: path, params: params, callback: block)
    }
    
    func request(to entity: FGEntity, relativePath path: String, params: [AnyHashable: Any], callback block: FGObjectBlock) -> NSURLConnection {
        return FGHTTP.shared().post(to: entity, relativePath: path, json: params, callback: {(_ jsonObj: Any, _ err: Error) -> Void in
            if err {
                //FGLogErrorWithClsAndFuncName("FGAdapterRequest: Failed to start adapter request: %@", err)
                BLOCK_SAFE_RUN(block, nil, err)
                return
            }
            else {
                var requestId = jsonObj["id"].toNSString()
                var commands: [Any] = [FGCommand(action: self.FGAdapterRequestCmdAsyncJob, argument: requestId, argument: "success"), FGCommand(action: self.FGAdapterRequestCmdAsyncJob, argument: requestId, argument: "failed")]
                var hub: FGSocket? = FGSession.shared().selectedEntity.room.hub
                if block {
                    self.requestIdsToCallbacks[requestId] = block
                }
                self.requestIdsToListeners[requestId] = FGCommandListener(hub, commands: commands, timeout: self.FGAdapterRequestTimeout, exactMatch: false, delegate: self)
            }
        })
    }
    
    func shoppingCartCheckout(to room: FGRoom, cart: FGShoppingCart, autoReplyMailboxId autoReplyMailboxIdOrNil: NSNumber, autoReplyBody autoReplyBodyorNil: String, extraParams: [AnyHashable: Any], callback block: FGObjectBlock) -> NSURLConnection {
        // construct path
        var path: String = "v3"
        path = URL(fileURLWithPath: path).appendingPathComponent(room.pathComponentWithParents).absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("store_shopping_carts").absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("\(cart.cartID)").absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("check_out").absoluteString
        var params = [AnyHashable: Any]()
        if cart.cartSelections.length {
            params["message"] = cart.cartSelections
        }
        if cart.partySize {
            params["guest_count"] = cart.partySize
        }
        if (autoReplyBodyorNil.characters.count ?? 0) && autoReplyMailboxIdOrNil {
            params["auto_reply_mailbox_id"] = autoReplyMailboxIdOrNil.description
            params["auto_reply_message"] = autoReplyBodyorNil
        }
        if cart.items().count {
            var itemIDsToNames = [AnyHashable: Any]()
            for item: FGShoppingCartItem in cart.items() {
                itemIDsToNames[item.agilysisID.stringValue] = item.node.title
            }
            params["mapping"] = itemIDsToNames
        }
        if extraParams.count {
            for (k, v) in extraParams { params.updateValue(v, forKey: k) }
        }
        return self.toEntity(room, relativePath: path, params: params, callback: block)
    }
    
    func getAvailableSpaTreatments(to room: FGRoom, location locationId: NSNumber, category categoryId: NSNumber, subcategory subcategoryId: NSNumber, callback block: FGArrayBlock) -> NSURLConnection {
        assert(locationId != 0, "Location ID must not be nil.")
        var params = [AnyHashable: Any]()
        params["location_id"] = locationId
        if categoryId != 0 {
            params["category_id"] = categoryId
        }
        if subcategoryId != 0 {
            params["sub_category_id"] = subcategoryId
        }
        return self.to(room, type: "spa", action: "get_available_spa_treatments", params: params, callback: {(_ obj: Any, _ err: Error) -> Void in
            var parsedTreatments = [Any]()
            if !err {
                var rawTreatments: [Any] = obj["treatments"]["treatment"].toNSArray()
                for rawTreatment: [AnyHashable: Any] in rawTreatments {
                    //We want to inject the locationId back into the dictionary
                    var mutableTreatment: [AnyHashable: Any] = rawTreatment
                    mutableTreatment["location_id"] = locationId
                    var treatment: FGSpaTreatment? = mutableTreatment
                    if treatment != nil {
                        parsedTreatments.append(treatment)
                    }
                }
            }
            BLOCK_SAFE_RUN(block, parsedTreatments, err)
        })
    }
    
    func getAvailableSpaTimeslots(to room: FGRoom, treatment: FGSpaTreatment, start startDate: Date, end endDate: Date, gender genderId: NSNumber, callback block: FGArrayBlock) -> NSURLConnection {
        assert(treatment, "Treatment must not be nil.")
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        var startDateString: String = dateFormatter.string(from: startDate)
        var endDateString: String = dateFormatter.string(from: endDate)
        var params = [AnyHashable: Any]()
        params["location_id"] = treatment.locationId
        params["treatment_id"] = treatment.treatmentId
        params["start_date_time"] = startDateString
        params["end_date_time"] = endDateString
        if genderId != 0 {
            params["gender_id"] = genderId
        }
        return self.to(room, type: "spa", action: "get_available_spa_timeslots", params: params, callback: {(_ obj: Any, _ err: Error) -> Void in
            var parsedTimeslots = [Any]()
            if !err {
                var rawTimeSlots: [Any] = obj["itinerary_time_slots_lists"]["itinerary_time_slots_list"]["itinerary_time_slots"]["itinerary_time_slot"]
                for rawTimeSlot: [AnyHashable: Any] in rawTimeSlots {
                    var rawTreatmentSlot: [AnyHashable: Any] = rawTimeSlot["treatment_time_slots"]["treatment_time_slot"]
                    if !rawTreatmentSlot.isEmpty {
                        parsedTimeslots.append(rawTreatmentSlot)
                    }
                }
            }
            BLOCK_SAFE_RUN(block, parsedTimeslots, err)
        })
    }
    
    func makeSpaAppointment(to room: FGRoom, treatment: FGSpaTreatment, date: Date, callback block: FGObjectBlock) -> NSURLConnection {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        var dateString: String = dateFormatter.string(from: date)
        var params = [AnyHashable: Any]()
        params["location_id"] = treatment.locationId
        params["treatment_id"] = treatment.treatmentId
        params["start_time"] = dateString
        return self.to(room, type: "spa", action: "make_spa_appointment", params: params, callback: {(_ obj: Any, _ err: Error) -> Void in
            var appointment: [AnyHashable: Any]? = nil
            if !err {
                appointment = obj["appointment"]
            }
            BLOCK_SAFE_RUN(block, appointment, err)
        })
    }
    func addWorkflowRequest(to room: FGRoom, issue issueId: NSNumber, remark: String, actionTime: Date, callback block: FGObjectBlock) -> NSURLConnection {
        assert(issueId != 0, "Issue ID is required to create a workflow request.")
        var params = [AnyHashable: Any]()
        params["issue_id"] = issueId
        if (remark.characters.count ?? 0) {
            params["remark"] = remark
        }
        if actionTime {
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            var dateString: String = dateFormatter.string(from: actionTime)
            params["action_time"] = dateString
        }
        return self.to(room, type: "workflow", action: "workflow_add_work", params: params, callback: {(_ obj: Any, _ err: Error) -> Void in
            if !err {
                print("Workflow response: \(obj)")
            }
            BLOCK_SAFE_RUN(block, obj, err)
        })
    }
    // MARK: - FGCommandListenerDelegate
    func listenerDidStart(_ lis: FGCommandListener) {
    }
    
    func listener(_ lis: FGCommandListener, foundMatchedIdx idx: Int, receivedCommand cmd: FGCommand?, orStoppedWithError err: Error?) {
        if (err != nil) || (cmd.arguments[1] == "failed") {
            var originalCommand: FGCommand? = lis.commands[0]
            var requestId: String? = originalCommand?.arguments[0]
            //FGLogErrorWithClsAndFuncName("FGAdapterRequest: Listener failed for request ID: %@", requestId)
            if requestId == nil {
                return
            }
            if err == nil {
                var info: [AnyHashable: Any] = [ NSLocalizedDescriptionKey : "Adapter request server error" ]
                err = Error(domain: FingiSDKErrorDomain, code: -1, userInfo: info)
            }
            //Clean up our state
            self.requestIdsToListeners.removeValueForKey(requestId)
            var block: FGDictionaryBlock = self.requestIdsToCallbacks[requestId]
            self.requestIdsToCallbacks.removeValueForKey(requestId)
            BLOCK_SAFE_RUN(block, nil, err)
        }else {
            var requestId: String = cmd.arguments[0]
            var room: FGRoom? = FGSession.shared().selectedEntity.room
            var path: String = "v3"
            path = URL(fileURLWithPath: path).appendingPathComponent(room?.pathComponentWithParents).absoluteString
            path = URL(fileURLWithPath: path).appendingPathComponent("service_requests").absoluteString
            path = URL(fileURLWithPath: path).appendingPathComponent(requestId).absoluteString
            FGHTTP.shared().getToEntity(room, relativePath: path, callback: {(_ jsonObj: Any, _ err: Error) -> Void in
                //Clean up our state
                self.requestIdsToListeners.removeValueForKey(requestId)
                var block: FGDictionaryBlock = self.requestIdsToCallbacks[requestId]
                self.requestIdsToCallbacks.removeValueForKey(requestId)
                if err != nil {
                    BLOCK_SAFE_RUN(block, nil, err)
                }
                else {
                    var response: Any? = jsonObj["service_request"]["response"]
                    BLOCK_SAFE_RUN(block, response, err)
                }
            })
        }
    }*/
}
