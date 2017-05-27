#import "RCTOkkamiSdk.h"
#import "RCTEventDispatcher.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
#import <CoreLocation/CoreLocation.h>
#import <Smooch/Smooch.h>

@implementation OkkamiSdk

// define macro
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

-(id)init {
    if ( self = [super init] ) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager startUpdatingLocation];
        [self.locationManager requestWhenInUseAuthorization];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
    }
    return self;
}

- (void)deletePList: (NSString*)plistname {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plistname]];
        NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
        //TODO: Handle/Log error
    }
}


RCT_EXPORT_METHOD(checkNotif
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Notifications.plist"];
    NSString *userPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *notification = [[NSMutableDictionary alloc] initWithContentsOfFile: plistPath];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile: userPath];
    //NSLog(@"USER ID %@", [userInfo objectForKey:@"userId"]);
    //NSLog(@"USER Info %@", userInfo);
    //NSLog(@"NOTIFICATIONS %@", notification);
    if(notification){
        if(notification[@"data"][@"property_smooch_app_token"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [Smooch destroy];
                SKTSettings *settings = [SKTSettings settingsWithAppToken:notification[@"data"][@"property_smooch_app_token"]];
                settings.enableAppDelegateSwizzling = NO;
                settings.enableUserNotificationCenterDelegateOverride = NO;
                [Smooch initWithSettings:settings];
                [Smooch login:[userInfo objectForKey:@"userId"] jwt:nil];
                [Smooch show];
                [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber -1;
                [self deletePList:@"Notifications"];
            });
        }
    }
}

#pragma mark Smooch Delegate

-(BOOL)conversation:(SKTConversation *)conversation shouldShowInAppNotificationForMessage:(SKTMessage *)message{
    return NO;
}

#pragma mark Pusher Delegate
-(void) pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel{
    NSLog(@"didSubscribeToChannel : %@", channel);
}
-(void) pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel{
    NSLog(@"didUnsubscribeFromChannel : %@", channel);
}
-(void) nativePusher:(PTNativePusher *)nativePusher didRegisterForPushNotificationsWithClientId:(NSString *)clientId{
    NSLog(@"didRegisterForPushNotificationsWithClientId : %@", clientId);
}
-(void) nativePusher:(PTNativePusher *)nativePusher didSubscribeToInterest:(NSString *)interestName{
    NSLog(@"didSubscribeToInterest : %@", interestName);
}
-(void) nativePusher:(PTNativePusher *)nativePusher didUnsubscribeFromInterest:(NSString *)interestName{
    NSLog(@"didUnsubscribeFromInterest : %@", interestName);
}


#pragma mark Notif Delegate

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"ERROR REGISTER: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"DID REGISTER REMOTE ???");
    [Smooch logout];
    [Smooch destroy];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appdel = appDelegate;
    [[self.appdel.pusher nativePusher] registerWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [Smooch logout];
    [Smooch destroy];
    NSLog(@"DID RECEIVE REMOTE ?");
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void
                                                                                                                               (^)(UIBackgroundFetchResult))completionHandler
{
    // iOS 10 will handle notifications through other methods
    
    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification: %@", userInfo );
    [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:userInfo[@"data"]];
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
    {
        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
        return;
    }
    ;
    // custom code to handle notification content
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:userInfo[@"data"]];
        SKTSettings *settings = [SKTSettings settingsWithAppToken:userInfo[@"data"][@"property_smooch_app_token"]];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings];
        [Smooch login:self.smoochUserId jwt:nil];
        [Smooch show];
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:userInfo[@"data"]];
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else
    {
        /*UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.body = userInfo[@"aps"][@"alert"][@"body"];
        content.sound = [UNNotificationSound defaultSound];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2
                                                                                                        repeats:NO];
        NSString *identifier = @"OkkamiLocalNotification";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                              content:content trigger:trigger];
        // Objective-C
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Something went wrong: %@",error);
            }
        }];*/
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        if (notification)
        {
            notification.fireDate = [[NSDate date] dateByAddingTimeInterval:2];
            notification.alertBody = userInfo[@"aps"][@"alert"][@"body"];
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        completionHandler( UIBackgroundFetchResultNewData );
    }
}

/*- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
    {
        return;
    }else{
        if(notification.userInfo[@"data"][@"property_smooch_app_token"]){
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:nil];
            [Smooch destroy];
            SKTSettings *settings = [SKTSettings settingsWithAppToken:notification.userInfo[@"data"][@"property_smooch_app_token"]];
            settings.enableAppDelegateSwizzling = NO;
            settings.enableUserNotificationCenterDelegateOverride = NO;
            [Smooch initWithSettings:settings];
            [Smooch login:self.smoochUserId jwt:nil];
            [Smooch show];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber -1;
        }
    }
}*/

-(void)conversation:(SKTConversation *)conversation didDismissViewController:(UIViewController *)viewController{
    [Smooch logout];
    [Smooch destroy];
}
-(void)conversation:(SKTConversation *)conversation willDismissViewController:(UIViewController *)viewController{
    [Smooch logout];
    [Smooch destroy];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog( @"Handle push from foreground" );
    NSLog(@"%@", notification.request.content.userInfo);
    if(notification.request.content.userInfo[@"SmoochNotification"]){
        completionHandler(UIUserNotificationTypeNone  | UIUserNotificationTypeBadge);
    }else{
        self.status = @"foreground";
        if(notification.request.content.userInfo[@"data"][@"command"]){
            [self.bridge.eventDispatcher sendAppEventWithName:notification.request.content.userInfo[@"data"][@"command"] body:nil];
        }else{
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        }
        completionHandler(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSLog( @"Handle push from background or closed" );
    //NSLog(@"%@", response.notification.request.content.userInfo);
    //NSLog(@"PROPERTY SMOOCH TOKEN-%@",response.notification.request.content.userInfo[@"data"][@"property_smooch_app_token"]);
    //NSLog(@"PROPERTY NAME%@",response.notification.request.content.userInfo[@"aps"][@"alert"][@"title"]);
    if(response.notification.request.content.userInfo[@"data"][@"property_smooch_app_token"]){
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:nil];
        [Smooch destroy];
        SKTSettings *settings = [SKTSettings settingsWithAppToken:response.notification.request.content.userInfo[@"data"][@"property_smooch_app_token"]];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings];
        [Smooch login:self.smoochUserId jwt:nil];
        [Smooch show];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber -1;
    }else if(response.notification.request.content.userInfo[@"data"][@"command"]){
        [self.bridge.eventDispatcher sendAppEventWithName:response.notification.request.content.userInfo[@"data"][@"command"] body:nil];
    }
    completionHandler();
}
#pragma mark LineSDKLoginDelegate

- (void)didLogin:(LineSDKLogin *)login
      credential:(LineSDKCredential *)credential
         profile:(LineSDKProfile *)profile
           error:(NSError *)error
{
    NSLog(@"come here ? %@", error);
    if (error) {
        NSLog(@"Error data : %@", error);
        self.loginRejecter([NSString stringWithFormat:@"%ld", error.code],error.description, error);
        // Login failed with an error. You can use the error parameter to help determine what the problem was.
    }
    else {
        
        // Login has succeeded. You can get the user's access token and profile information.
        self.accessToken = credential.accessToken.accessToken;
        self.userId = profile.userID;
        self.displayName = profile.displayName;
        self.statusMessage = profile.statusMessage;
        // If the user does not have a profile picture set, pictureURL will be nil
        if (profile.pictureURL) {
            self.pictureURL = profile.pictureURL.absoluteString;
        }else{
            self.pictureURL = @"";
        }
        NSError *error;
        self.lineData = [NSDictionary dictionaryWithObjectsAndKeys:self.accessToken,@"accessToken",self.userId,@"user_id",self.displayName, @"display_name", self.pictureURL,@"picture", nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.lineData
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString* line;
        line = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.loginResolver(line);
        [self.bridge.eventDispatcher sendAppEventWithName:@"executeFromLine" body:line];
        
    }
}



RCT_EXPORT_METHOD(lineLogin
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [LineSDKLogin sharedInstance].delegate = self;
    NSLog(@"equal to line");
    [[LineSDKLogin sharedInstance] startLogin];
    self.loginResolver = resolve;
    self.loginRejecter = reject;
    
}

/**
 * The purpose of this method is to provide general purpose way to call any core endpoint.
 * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
 * <p>
 * on success : downloadFromCorePromise.resolve(coreResponseJSONString)
 * on failure:  downloadFromCorePromise.reject(Throwable e)
 *
 * @param endPoint                full core url . https://api.fingi.com/devices/v1/register
 * @param getPost                 "GET" or "POST"
 * @param payload                 JSON encoded payload if it is POST
 * @param downloadFromCorePromise
 */


// Wait for location callbacks
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"tess");
}

- (CLLocationDegrees)deviceLat
{
    return self.locationManager.location.coordinate.latitude;
}


- (CLLocationDegrees)deviceLong
{
    return self.locationManager.location.coordinate.longitude;
}

RCT_EXPORT_METHOD(executeCoreRESTCall
                  
                  :(NSString*)endPoint
                  :(NSString*)getPost
                  :(NSString*)payLoad
                  :(NSString*)secret
                  :(NSString*)token
                  :(BOOL) force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [main executeCoreRESTCallWithApicore:endPoint apifunc:getPost payload:payLoad secret:secret token:token force:force completion:^(NSString* callback, NSError* error) {
            
            NSLog(@"callback %@", callback);
            NSLog(@"error %@", error);
            
            if (error == NULL) {
                resolve(callback);
                [self.bridge.eventDispatcher sendAppEventWithName:@"executeCoreRESTCall" body:callback];
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
            
        }];
    });
}

/**
 * Connects to hub using the presets and attempts to login ( send IDENTIFY)
 * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
 * on success: hubConnectionPromise.resolve(true)
 * on failure:  hubConnectionPromise.reject(Throwable e)
 * Native module should also take care of the PING PONG and reconnect if PING drops
 *
 * @param secrect secrect obtained from core
 * @param token   token obtained from core
 * @param hubConnectionPromise
 */

-(void)sendAnEvent:(NSString*)eventName :(NSDictionary*)userInfo{
    NSString *event = eventName;
    NSString *appToken = userInfo[@"data"][@"property_smooch_app_token"];
    [self.bridge.eventDispatcher sendAppEventWithName:event body:@{@"apptoken": appToken}];
    
}
- (void)listenerOkkami:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSString *event = [theData objectForKey:@"event"];
        NSString *command = [theData objectForKey:@"command"];
        if (command != nil) {
            [self.bridge.eventDispatcher sendAppEventWithName:event body:@{@"command": command}];
        }else{
            [self.bridge.eventDispatcher sendAppEventWithName:event body:nil];
        }
    }
    
}

RCT_EXPORT_METHOD(connectToHub
                  :(NSString*)uid
                  :(NSString*)secret
                  :(NSString*)token
                  :(NSString*)hubUrl
                  :(NSString*)hubPort
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    self.main = main;
    NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];
    [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:self.main.notificationName object:nil];
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    UInt16 portNumber = [[formatter numberFromString:hubPort] unsignedShortValue];
    [self.main connectToHubWithNotif:defaultNotif uid:uid secret:secret token:token hubUrl:hubUrl hubPort:portNumber completion:^(NSError * error) {
        if(error == nil){
            resolve(@YES);
        }else{
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Not connected To Room" forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"E_ROOM_NOT_CONNECTED" code:1200 userInfo:details];
            reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
        }
    }];
}


/**
 * Disconnects and cleans up the existing connection
 * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
 * on success: hubDisconnectionPromise.resolve(true)
 * on failure:  hubDisconnectionPromise.reject(Throwable e)
 *
 * @param hubDisconnectionPromise
 */
RCT_EXPORT_METHOD(disconnectFromHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:200 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.main disconnectFromHubWithCompletion:^(NSError * error) {
            if (error == nil) {
                [self.bridge.eventDispatcher sendAppEventWithName:@"disconnectFromHub" body:nil];
                //ok
                resolve(@YES);
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
        }];
    }
}

/**
 * Disconnects and cleans up the existing connection
 * Then attempt to connect to hub again.
 * on success ( hub has been successfully reconnected and logged in ) : hubReconnectionPromise.resolve(true)
 * on failure:  hubReconnectionPromise.reject(Throwable e)
 *
 * @param hubReconnectionPromise
 */

RCT_EXPORT_METHOD(reconnectToHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:200 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];
        [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:self.main.notificationName object:nil];    
        [self.main reconnectToHubWithNotif: defaultNotif completion:^(NSError * error) {
            if (error == nil) {
                [self.bridge.eventDispatcher sendAppEventWithName:@"reconnectToHub" body:nil];
                //ok
                resolve(@YES);
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
        }];
    }
    
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
 * on failure:  hubDisconnectionPromise.reject(Throwable e)
 *
 * @param sendMessageToHubPromise
 */

RCT_EXPORT_METHOD(sendCommandToHub
                  
                  :(NSString*)command
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:200 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [self.main sendCommandToHubWithCommand:command completion:^(NSError * error) {
            if (error == nil) {
                //[self.bridge.eventDispatcher sendAppEventWithName:@"onHubCommand" body:@{@"command": command}];
                //ok
                resolve(@YES);
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
        }];
    }

    
}



/**
 * if hub is currently connected + logged in :
 * hubLoggedPromise.resolve(true);
 * else
 * hubLoggedPromise.resolve(false);
 *
 * @param hubLoggedPromise
 */

RCT_EXPORT_METHOD(isHubLoggedIn
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"OkkamiNotConnectedToHub" code:200 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [self.main isHubLoggedInCompletion:^(NSNumber * number) {
            [self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:nil];
            //ok
            BOOL boolValue = [number boolValue];
            if (boolValue) {
                resolve(@YES);
            }else{
                resolve(@NO);
            }
        }];
    }
}

/**
 * if hub is currently connected ( regardless of logged in ) :
 * hubConnectedPromise.resolve(true);
 * else
 * hubConnectedPromise.resolve(false);
 *
 * @param hubConnectedPromise
 */


RCT_EXPORT_METHOD(isHubConnected
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"OkkamiNotConnectedToHub" code:200 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [self.main isHubConnectedWithCompletion:^(NSNumber * number) {
            [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
            //ok
            BOOL boolValue = [number boolValue];
            
            if (boolValue) {
                resolve(@YES);
            }else{
                resolve(@NO);
            }
        }];
    }
    
}

/*-------------------------------------- Smooch   --------------------------------------------------*/




RCT_EXPORT_METHOD(convertTime
                  
                  :(double) time
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"HOHOHO");
        NSString *jsonObj = [main convertTimeWithNumber:time];
        resolve(jsonObj);
        //NSString *jsonObj = [smooch getConversationsListWithArray:smoochAppToken userID: userID];
        //resolve(jsonObj);
    });//    resolve([self.smooch getConversationsList]);
}
RCT_EXPORT_METHOD(getConversationsList
                  
                  :(NSArray*) smoochAppToken
                  :(NSString*) userID
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    
    if(!self.smooch){
        OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstanceWithAppToken:smoochAppToken[0]];
        self.smooch = smooch;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *jsonObj = [self.smooch getConversationsListWithArray:smoochAppToken userID: userID];
        resolve(jsonObj);
    });
}


RCT_EXPORT_METHOD(openChatWindow
                  
                  :(NSString *) smoochAppToken
                  :(NSString *) userID
                  :(NSString *) hotelName
                  :(NSString*) color
                  :(NSString*) textColor
                  :(BOOL) rgbColor
                  :(BOOL) rgbTextColor
                                    
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    /*OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstanceWithAppToken:smoochAppToken];
    self.smooch = smooch;
    NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];
    [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:self.smooch.notificationName object:nil];
    [self.smooch addNotifWithNotif: defaultNotif];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.smooch smoochChatWithUser:userID color: color textColor: textColor rgbColor: rgbColor rgbTextColor: rgbTextColor];
        //[UIApplication sharedApplication].applicationIconBadgeNumber = [self.smooch getUnreadMessageCount];
    });*/
    dispatch_async(dispatch_get_main_queue(), ^{
        [Smooch destroy];
        SKTSettings *settings = [SKTSettings settingsWithAppToken:smoochAppToken];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings];
        [Smooch login:self.smoochUserId jwt:nil];
        [Smooch show];
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
    });
}


RCT_EXPORT_METHOD(getUnreadMessageCount
                  
                  :(NSString *) smoochAppToken
                  :(NSString *) userID
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    NSUInteger unreadMessage = [self.smooch getUnreadMessageCount];
    NSString *unread = [NSString stringWithFormat:@"%ld", unreadMessage];
    resolve(unread);
}


RCT_EXPORT_METHOD(setAppBadgeIcon :(NSInteger)badgeIcon
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeIcon;
}

RCT_EXPORT_METHOD(logoutChatWindow
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    [self.smooch okkamiLogout];
    NSLog(@"UNSUBSCRIBE TO %@", self.appdel.channel_name);
    [[self.appdel.pusher nativePusher] unsubscribe:self.appdel.channel_name];
    [self deletePList:@"UserInfo"];
    [self deletePList:@"Notifications"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


RCT_EXPORT_METHOD(loginChatWindow
                  
                  :(NSString *) userID
                  :(NSString *) appToken
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstanceWithAppToken:appToken];
    self.smooch = smooch;
    NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];
    [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:self.smooch.notificationName object:nil];
    [self.smooch addNotifWithNotif: defaultNotif];
    [self.smooch smoochLoginWithUser:userID];
}



RCT_EXPORT_METHOD(setFacebookEnvironment
                  
                  :(NSDictionary *) data
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    NSString *newPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSLog(@"PATH %@", newPath);
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: newPath];

    //load from savedStock example int value
    NSString* value;
    value = [savedStock objectForKey:@"FacebookAppID"];
    NSLog(@"VALUE %@", value);
    
    NSMutableDictionary *newData = [[NSMutableDictionary alloc] initWithContentsOfFile: newPath];
    NSMutableArray* newArray = [NSMutableArray array];
    [newData setObject:data[@"fbAppId"] forKey:@"FacebookAppID"];

    NSMutableArray* oldArray;
    oldArray = [savedStock objectForKey:@"CFBundleURLTypes"];
    
    newArray[0] = oldArray[0];
    newArray[1] = [NSMutableDictionary dictionary];
    newArray[1][@"CFBundleURLSchemes"] = [NSMutableArray array];
    newArray[1][@"CFBundleURLSchemes"][0] = [NSString stringWithFormat:@"fb%@", data[@"fbAppId"]];
    
    [newData setObject:newArray forKey:@"CFBundleURLTypes"];
    [newData writeToFile: newPath atomically:YES];
    
    NSString* value2;
    NSMutableDictionary *savedStock2 = [[NSMutableDictionary alloc] initWithContentsOfFile: newPath];
    value2 = [savedStock2 objectForKey:@"FacebookAppID"];
    NSLog(@"VALUE %@", value2);
    
    //set app id using fbsdk
    [FBSDKSettings setAppID:data[@"fbAppId"]];
    //[FBSDKSettings setAppURLSchemeSuffix:[NSString stringWithFormat:@"fb%@", data[@"fbAppId"]]];
    
}

RCT_EXPORT_METHOD(setLineEnvironment
                  
                  :(NSDictionary *) data
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    NSString *newPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSLog(@"PATH %@", newPath);
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: newPath];
    
    NSMutableDictionary* value;
    value = [savedStock objectForKey:@"LineSDKConfig"];
    NSLog(@"VALUE %@", value[@"ChannelID"]);
    
    NSMutableDictionary *newData = [[NSMutableDictionary alloc] initWithContentsOfFile: newPath];
    NSMutableDictionary* newValue = [NSMutableDictionary dictionaryWithObjectsAndKeys:data[@"lineAppId"],@"ChannelID", nil];
    
    [newData setObject:newValue forKey:@"LineSDKConfig"];
    [newData writeToFile: newPath atomically:YES];
    
    NSMutableDictionary* value2;
    NSMutableDictionary *savedStock2 = [[NSMutableDictionary alloc] initWithContentsOfFile: newPath];
    value2 = [savedStock2 objectForKey:@"LineSDKConfig"];
    NSLog(@"VALUE %@", value2[@"ChannelID"]);
    
}




RCT_EXPORT_METHOD(setUserId
                  
                  :(NSString *) userId
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appdel = appDelegate;
    NSString *channelName = [NSString stringWithFormat:@"mobile_user_%@", userId];
    self.smoochUserId = userId;
    NSLog(@"===SET USER ID====%@", channelName);
    [self.appdel setUser_id:userId];
    [self.appdel setChannel_name:channelName];
    [[self.appdel.pusher nativePusher] subscribe:channelName];

    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath: plistPath])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"UserInfo" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath:plistPath error:&error];
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userId",
                          nil];
    NSLog(@"===PLIST PATH====%@", plistPath);
    [dict writeToFile:plistPath atomically: YES];
    
    // subscribe to channel and bind to event
    //PTPusherChannel *channel = [self.appdel.pusher  subscribeToChannelNamed:channelName];
    /*[channel bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *channelEvent) {
        // channelEvent.data is a NSDictianary of the JSON object received
        NSString *message = [channelEvent.data objectForKey:@"message"];
        NSLog(@"message received: %@", message);
    }];*/

    [self.appdel.pusher connect];
}

/*-------------------------------------- Utility   --------------------------------------------------*/


/**
 * Delete stored information of the user
 */

/*RCT_EXPORT_METHOD(wipeUserData
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}*/

/**
 * Entry point of the native sdk
 */


RCT_EXPORT_METHOD(start
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    NSString* udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* payload = [NSString stringWithFormat:@"{\"uid\":\"%@\"}", udid];
}

/**
 * restart the native sdk,
 * basically stop and call the entry point of the sdk
 */

/*
RCT_EXPORT_METHOD(restart
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    
}*/

/*---------------------------------------------------------------------------------------------------*/


/*-------------------------------------- Hub & Core -------------------------------------------------*/

/**
 * Connect to room. Applicable to downloadable apps
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 * The native module should take care of persisting the device secret and token obtained from core
 * and making sure it is secure/encrypted
 */
/*
RCT_EXPORT_METHOD(connectToRoom
                  :(NSString*)username
                  :(NSString*)password
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main connectToRoomWithRoom:@"demo3" token:@"1234"];
    [self.bridge.eventDispatcher sendAppEventWithName:@"connectToRoom" body:@{@"command": @"Connect To Room"}];

    
}
*/

/**
 * Disconnects from the current room. Applicable to downloadable apps.
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 */
/*
RCT_EXPORT_METHOD(disconnectFromRoom
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main disconnectFromRoom];
    [self.bridge.eventDispatcher sendAppEventWithName:@"disconnectFromRoom" body:@{@"command": @"Disconnect From Room"}];
}*/

/**
 * Registers the device with a room using the given UID .
 * Applicable to property locked Apps
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 * The native module should take care of persisting the device secret and token obtained from core
 * and making sure it is secure/encrypted
 */
/*
RCT_EXPORT_METHOD(registerToCore
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}*/

/**
 * Connects to hub using the presets and attempts to login ( send IDENTIFY)
 * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
 * on success: resolve(true)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 * Native module should also take care of the PING PONG and reconnect if PING drops
 */
/*
RCT_EXPORT_METHOD(connectToHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
 
    
    RCTOkkamiMain *helloWorld = [RCTOkkamiMain newInstance];
    [helloWorld getGuestService];
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
*/

/**
 * Disconnects and cleans up the existing connection
 * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
 * on success: resolve(true)
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 *
 */
/*
RCT_EXPORT_METHOD(disconnectFromHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubDisconnected" body:nil];
}

*/

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
/*
RCT_EXPORT_METHOD(sendCommandToHub:(NSString*)command
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubCommand"
                                                 body:@{@"command": @"1234 2311 Default | POWER light-1 ON"}];
    
}
*/

/**
 * downloads presets from core.
 * If force == YES, force download from core
 * If force == NO, and there is already presets from core, reply with that
 * on success : resolve(coreResponseJSONString)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 */
/*
RCT_EXPORT_METHOD(downloadPresets
                  :(BOOL)force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main downloadPresetsWithForce:1];
    [self.bridge.eventDispatcher sendAppEventWithName:@"downloadPresets"
                                                 body:@{@"command": @"Download Presets"}];
}
*/
/**
 * Similar strategy as downloadPresets method
 *
 */
/*
RCT_EXPORT_METHOD(downloadRoomInfo
                  :(BOOL)force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main downloadRoomInfoWithForce:1];
    [self.bridge.eventDispatcher sendAppEventWithName:@"downloadRoomInfo"
                                                 body:@{@"command": @"Download Room Info"}];
}
*/
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
/*
RCT_EXPORT_METHOD(downloadFromCore
                  
                  :(NSString*)endPoint
                  :(NSString*)getPost
                  :(NSString*)payLoad
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}

*/
/**
 * if hub is currently connected + logged in :
 * resolve(true);
 * else
 * resolve(false);
 */
/*
RCT_EXPORT_METHOD(isHubLoggedIn
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:@{@"command": @"Hub Logged In"}];
    //ok
    resolve(@YES);
    
}*/

/**
 * if hub is currently connected ( regardless of logged in )  :
 * resolve(true);
 * else
 * resolve(false);
*
 */
/*
RCT_EXPORT_METHOD(isHubConnected
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
    //ok
    resolve(@YES);
    
}
*/


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
/*
RCT_EXPORT_METHOD(dial
                  
                  :(NSString*)calledNumber
                  :(BOOL)preferSip
            
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}
*/

/**
 * Attempt to accept an incoming voip call
 */

/*
RCT_EXPORT_METHOD(receive
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{

    
}
 */
/**
 * Hangup an incoming / ongoing voip Call
 *
 * @param hangupPromise
 */
/*
RCT_EXPORT_METHOD(hangup
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    //ok
    resolve(@YES);
    
}
*/





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
