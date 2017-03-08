#import "RCTBridge.h"
#import <LineSDK/LineSDK.h>

@import RCTokkamiiossdk;


@interface OkkamiSdk : NSObject <RCTBridgeModule, LineSDKLoginDelegate>
@property (nonatomic, copy)NSString * accessToken;
@property (nonatomic, copy)NSString * userId;
@property (nonatomic, copy)NSString * displayName;
@property (nonatomic, copy)NSString * statusMessage;
@property (nonatomic, copy)NSString * pictureURL;
@property (copy, nonatomic) NSDictionary * lineData;
@property (strong, nonatomic) RCTPromiseResolveBlock loginResolver;
@property (strong, nonatomic) RCTPromiseRejectBlock loginRejecter;
@property (strong, nonatomic) RCTOkkamiMain* main;
@end
