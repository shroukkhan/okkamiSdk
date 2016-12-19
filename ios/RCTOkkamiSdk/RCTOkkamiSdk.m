#import "RCTOkkamiSdk.h"
#import "RCTEventDispatcher.h"

@implementation OkkamiSdk

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(connectToRoom
                  :(NSString*)username
                  :(NSString*)password
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (true) {
        resolve(@"{}");
        
    } else {
        // example
        /* NSError *error = ...
         reject(@"no_events", @"There were no events", error);
         */
    }
}


RCT_EXPORT_METHOD(disconnectFromRoom
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


RCT_EXPORT_METHOD(registerToCore
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


RCT_EXPORT_METHOD(connectToHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


RCT_EXPORT_METHOD(disconnectFromHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


RCT_EXPORT_METHOD(sendCommandToHub:(NSString*)command
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


RCT_EXPORT_METHOD(downloadPresets
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


RCT_EXPORT_METHOD(downloadRoomInfo:(NSString*)endPoint
                  :(NSString*)getPost
                  :(NSString*)payLoad
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}


RCT_EXPORT_METHOD(isHubLoggedIn
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    //ok
    resolve(@YES);
    
}

RCT_EXPORT_METHOD(isHubConnected
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
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







@end
