#import "RCTBridge.h"
#import <UserNotifications/UserNotifications.h>
#import <LineSDK/LineSDK.h>
#import "RCTBridgeModule.h"
#import <CoreLocation/CoreLocation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Pusher.h"
#import "AppDelegate.h"
#import <Smooch/Smooch.h>

@import RCTokkamiiossdk;

@interface OkkamiSdk : NSObject <RCTBridgeModule, LineSDKLoginDelegate, CLLocationManagerDelegate,UNUserNotificationCenterDelegate, UIApplicationDelegate, SKTConversationDelegate, PTPusherDelegate>
@property (nonatomic, copy)NSString * accessToken;
@property (nonatomic, copy)NSString * userId;
@property (nonatomic, copy)NSString * displayName;
@property (nonatomic, copy)NSString * statusMessage;
@property (nonatomic, copy)NSString * pictureURL;
@property (nonatomic, copy)NSString * smoochUserId;
@property (nonatomic, copy)NSString * status;
@property (copy, nonatomic) NSDictionary * lineData;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (strong, nonatomic) RCTPromiseResolveBlock loginResolver;
@property (strong, nonatomic) RCTPromiseRejectBlock loginRejecter;
@property (strong, nonatomic) RCTOkkamiMain* main;
@property (strong, nonatomic) RCTEventDispatcher* event;
@property (strong, nonatomic) OkkamiSmoochChat* smooch;
@property (strong, nonatomic) AppDelegate* appdel;
@end
