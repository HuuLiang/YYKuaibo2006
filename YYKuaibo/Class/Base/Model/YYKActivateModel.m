//
//  YYKActivateModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKActivateModel.h"

static NSString *const kSuccessResponse = @"SUCCESS";

@implementation YYKActivateModel

+ (instancetype)sharedModel {
    static YYKActivateModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[YYKActivateModel alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [NSString class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)activateWithCompletionHandler:(YYKActivateHandler)handler {
    NSString *sdkV = [NSString stringWithFormat:@"%d.%d",
                      __IPHONE_OS_VERSION_MAX_ALLOWED / 10000,
                      (__IPHONE_OS_VERSION_MAX_ALLOWED % 10000) / 100];
    
    NSDictionary *params = @{@"cn":YYK_CHANNEL_NO,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"sms":@"00000000000",
                             @"cw":@(kScreenWidth),
                             @"ch":@(kScreenHeight),
                             @"cm":[YYKUtil deviceName],
                             @"mf":[UIDevice currentDevice].model,
                             @"sdkV":sdkV,
                             @"cpuV":@"",
                             @"appV":[YYKUtil appVersion],
                             @"appVN":@"",
                             @"ccn":YYK_PACKAGE_CERTIFICATE,
                             @"operator":[YYKNetworkInfo sharedInfo].carriarName ?: @"",
                             @"systemVersion":[UIDevice currentDevice].systemVersion};
    
    BOOL success = [self requestURLPath:YYK_ACTIVATE_URL withParams:params responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage) {
        NSString *userId;
        if (respStatus == YYKURLResponseSuccess) {
            NSString *resp = self.response;
            NSArray *resps = [resp componentsSeparatedByString:@";"];
            
            NSString *success = resps.firstObject;
            if ([success isEqualToString:kSuccessResponse]) {
                userId = resps.count == 2 ? resps[1] : nil;
            }
        }
        
        if (handler) {
            handler(respStatus == YYKURLResponseSuccess && userId, userId);
        }
    }];
    return success;
}

@end
