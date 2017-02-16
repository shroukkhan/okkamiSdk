#import "RCTOkkamiSdk.h"
#import "RCTEventDispatcher.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
//#import <RCTOkkamiSdkImplementation/RCTOkkamiSdkImplementation-Swift.h>

@implementation OkkamiSdk

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();



/*-------------------------------------- Utility   --------------------------------------------------*/


/**
 * Delete stored information of the user
 */
RCT_EXPORT_METHOD(wipeUserData
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}

/**
 * Entry point of the native sdk
 */

RCT_EXPORT_METHOD(start
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main preConnect];
    [self.bridge.eventDispatcher sendAppEventWithName:@"onStart" body:@{@"command": @"On Start"}];
}

/**
 * restart the native sdk,
 * basically stop and call the entry point of the sdk
 */
RCT_EXPORT_METHOD(restart
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    
}

/*---------------------------------------------------------------------------------------------------*/


/*-------------------------------------- Hub & Core -------------------------------------------------*/

/**
 * Connect to room. Applicable to downloadable apps
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 * The native module should take care of persisting the device secret and token obtained from core
 * and making sure it is secure/encrypted
 */
RCT_EXPORT_METHOD(connectToRoom
                  :(NSString*)username
                  :(NSString*)password
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main connectToRoomWithRoom:@"demo3" token:@"1234"];
    [self.bridge.eventDispatcher sendAppEventWithName:@"connectToRoom" body:@{@"command": @"Connect To Room"}];
/* Example for michael
    MyOkkamiSDKImplementationLibrary should be a swift library [ framework ? ]
    @try {
        NSString * x = [MyOkkamiSDKImplementationLibrary connectToRoom:username :password];
        resolve(x);
    }
    @catch (NSException *exception) {
        reject(@"xxx", @"xxx", exception);
    }
    @finally {
        
    }
  
 */
    
}


/**
 * Disconnects from the current room. Applicable to downloadable apps.
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 */
RCT_EXPORT_METHOD(disconnectFromRoom
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main disconnectFromRoom];
    [self.bridge.eventDispatcher sendAppEventWithName:@"disconnectFromRoom" body:@{@"command": @"Disconnect From Room"}];
}

/**
 * Registers the device with a room using the given UID .
 * Applicable to property locked Apps
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 * The native module should take care of persisting the device secret and token obtained from core
 * and making sure it is secure/encrypted
 */
RCT_EXPORT_METHOD(registerToCore
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}

/**
 * Connects to hub using the presets and attempts to login ( send IDENTIFY)
 * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
 * on success: resolve(true)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 * Native module should also take care of the PING PONG and reconnect if PING drops
 */
RCT_EXPORT_METHOD(connectToHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    /*RCTOkkamiMain * helloWorld = [RCTOkkamiMain newInstance];
    [helloWorld setupRxWithCompletion:^(NSString *test){
        //NSLog(@"Test Dictionary return : %@", test);
        NSDictionary *props = test;
        [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:@{
                                                                                   @"currentData":props
                                                                                   }];
    }];*/
    
    RCTOkkamiMain *helloWorld = [RCTOkkamiMain newInstance];
    //[helloWorld preConnect];
    //[helloWorld connectToRoom];
    //[helloWorld postToken];
    
    //RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:self.bridge moduleName:@"ImageBrowserApp" initialProperties:[helloWorld setupRx]];
    //NSString *test = [helloWorld setupRx];
//    if (test) {
//        resolve(test);
//    } else {
//        //reject(test);
//    }
    
}


/**
 * Disconnects and cleans up the existing connection
 * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
 * on success: resolve(true)
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 *
 */
RCT_EXPORT_METHOD(disconnectFromHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubDisconnected" body:nil];
}



/**
 * Send command to hub. a command can look like this:
 * POWER light-1 ON
 * 2311 Default | POWER light-1 ON
 * 1234 2311 Default | POWER light-1 ON
 * <p>
 * The native module should fill in the missing info based on the command received
 * such as filling in room , group , none if not provided and skip those if provied already
 * on success ( successful write ) : sendMessageToHubPromise.resolve(true)
 * on failure:  hubDisconnectionPromise.reject(@"xxx", @"xxx", NSError * error)
 */
RCT_EXPORT_METHOD(sendCommandToHub:(NSString*)command
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubCommand"
                                                 body:@{@"command": @"1234 2311 Default | POWER light-1 ON"}];
    
}


/**
 * downloads presets from core.
 * If force == YES, force download from core
 * If force == NO, and there is already presets from core, reply with that
 * on success : resolve(coreResponseJSONString)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 */
RCT_EXPORT_METHOD(downloadPresets
                  //:(BOOL)force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main downloadPresetsWithForce:1];
    [self.bridge.eventDispatcher sendAppEventWithName:@"downloadPresets"
                                                 body:@{@"command": @"Download Presets"}];
}

/**
 * Similar strategy as downloadPresets method
 *
 */
RCT_EXPORT_METHOD(downloadRoomInfo
                  //:(BOOL)force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}

/**
 * The purpose of this method is to provide general purpose way to call any core endpoint.
 * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
 * <p>
 * on success : resolve(coreResponseJSONString)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 *
 * @param endPoint                full core url . https://api.fingi.com/devices/v1/register
 * @param getPost                 "GET" or "POST"
 * @param payload                 JSON encoded payload if it is POST
 */
RCT_EXPORT_METHOD(downloadFromCore
                  
                  :(NSString*)endPoint
                  :(NSString*)getPost
                  :(NSString*)payLoad
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


/**
 * if hub is currently connected + logged in :
 * resolve(true);
 * else
 * resolve(false);
 */
RCT_EXPORT_METHOD(isHubLoggedIn
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:@{@"command": @"Hub Logged In"}];
    //ok
    resolve(@YES);
    
}

/**
 * if hub is currently connected ( regardless of logged in )  :
 * resolve(true);
 * else
 * resolve(false);
*
 */
RCT_EXPORT_METHOD(isHubConnected
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
    //ok
    resolve(@YES);
    
}



//Events emission
/*
 *  onHubCommand
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubCommand"
 *       body:@{@"command": @"1234 2311 Default | POWER light-1 ON"}];
 *
 *
 *  onHubConnected
 *   
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
 *
 *
 *  onHubLoggedIn ( when IDENTIFIED is received )
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:nil];
 *
 *
 *  onHubDisconnected
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubDisconnected" body:nil];
 *
 *
 * */



/*---------------------------------------------------------------------------------------------------*/

/*-------------------------------------- SIP / PhoneCall --------------------------------------------*/


// SIP should be enabled / disabled autometically by the native sdk based on what is set in the preset
// If Downloadable app, registration should not persist when app is in background
// If property locked app, registration should persist even in background . Not applicable to iOS apps .
// Registration should happen as soon as downloadPresets is successful


/**
 * Dial a number. if voip Not available, dial using native dialer
 *
 * @param calledNumber
 * @param preferSip
 */
RCT_EXPORT_METHOD(dial
                  
                  :(NSString*)calledNumber
                  :(BOOL)preferSip
            
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


/**
 * Attempt to accept an incoming voip call
 */
RCT_EXPORT_METHOD(receive
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{

    
}
/**
 * Hangup an incoming / ongoing voip Call
 *
 * @param hangupPromise
 */
RCT_EXPORT_METHOD(hangup
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    //ok
    resolve(@YES);
    
}


//Events emission
/*
 *  onIncomingCall
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onIncomingCall"
 *       body:@{@"caller": @"CALLER_NUMBER",  @"uniqueId":  @"CALL_UNIQUE_ID", @"eventData":  @"JSON_STRING"}];
 *
 *  onSipEvent
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onSipEvent"
 *       body:@{@"eventNumber": @"SIP_EVENT_NUMBER_LIKE_200_400_404_ETC", @"JSON_STRING"}];
 *
 *  onCallHangup
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onCallHangup"
 *       body:@{@"caller": @"CALLER_NUMBER",  @"uniqueId":  @"CALL_UNIQUE_ID", @"eventData":  @"JSON_STRING"}];
 *
 *  onSipRegistrationStatusChanged
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onSipRegistrationStatusChanged"
 *       body:@{@"status": @"STATUS", @"eventData":  @"JSON_STRING"}]; // status should be one of : REGISTERING, REGISTERED , AUTHENTICATION_FAILURE , UNREGISTERED ,
 */




/*---------------------------------------------------------------------------------------------------*/



/*-------------------------------------- WIFI --------------------------------------------------------*/

//wifi status is to be managed by the native sdk internally.
//for property locked app, the sdk should set SSID and password as soon as downloadPresets is successful


//Events emission
/*
 *
 *  onWifiStatusChanged
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onWifiStatusChanged"
 *       body:@{@"status": @"STATUS", @"eventData":  @"JSON_STRING"}]; // status should be one of : CONNECTING,CONNECTED,DISCONNECTED
 **/


/*---------------------------------------------------------------------------------------------------*/


/*-------------------------------------- Keys --------------------------------------------------------*/

//?? need discussion


/*---------------------------------------------------------------------------------------------------*/




@end
