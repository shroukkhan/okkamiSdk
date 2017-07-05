#import "RCTBridge.h"
#import <UserNotifications/UserNotifications.h>
#import <LineSDK/LineSDK.h>
#import "RCTBridgeModule.h"
#import <CoreLocation/CoreLocation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Pusher.h"
#import "AppDelegate.h"
#import <SafariServices/SafariServices.h>
#import <Smooch/Smooch.h>

@import RCTokkamiiossdk;

@interface OkkamiSdk : NSObject <RCTBridgeModule, LineSDKLoginDelegate, CLLocationManagerDelegate,UNUserNotificationCenterDelegate, UIApplicationDelegate, SKTConversationDelegate, PTPusherDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, copy)NSString * accessToken;
@property (nonatomic, copy)NSString * userId;
@property (nonatomic, copy)NSString * displayName;
@property (nonatomic, copy)NSString * statusMessage;
@property (nonatomic, copy)NSString * pictureURL;
@property (nonatomic, copy)NSString * smoochUserId;
@property (nonatomic, copy)NSString * hotelName;
@property (nonatomic, copy)NSString * status;
@property (nonatomic, copy)NSString * currentSmoochToken;
@property (copy, nonatomic) NSDictionary * lineData;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (strong, nonatomic) RCTPromiseResolveBlock loginResolver;
@property (strong, nonatomic) RCTPromiseRejectBlock loginRejecter;
@property (strong, nonatomic) RCTOkkamiMain* main;
@property (strong, nonatomic) RCTEventDispatcher* event;
@property (strong, nonatomic) OkkamiSmoochChat* smooch;
@property (strong, nonatomic) AppDelegate* appdel;
@property (strong, nonatomic) UIViewController* currentViewController;
@property (nonatomic, assign)BOOL isSmoochShow;
@end
