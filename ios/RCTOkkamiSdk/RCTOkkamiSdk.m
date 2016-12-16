#import "RCTOkkamiSdk.h"

@implementation OkkamiSdk

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(okkamiSdk,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@"Hello World!");
}

@end
