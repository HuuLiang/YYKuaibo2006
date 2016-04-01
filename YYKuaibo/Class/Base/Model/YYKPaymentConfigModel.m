//
//  YYKPaymentConfigModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPaymentConfigModel.h"

static NSString *const kSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

@implementation YYKPaymentConfigModel

+ (Class)responseClass {
    return [YYKPaymentConfig class];
}

+ (instancetype)sharedModel {
    static YYKPaymentConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (YYKURLRequestMethod)requestMethod {
    return YYKURLPostRequest;
}

+ (NSString *)signKey {
    return kSignKey;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":YYK_REST_APP_ID,
                                   @"key":kSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":YYK_CHANNEL_NO,
                                   @"pV":YYK_REST_PV };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":YYK_REST_APP_ID};
}

- (BOOL)fetchConfigWithCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_PAYMENT_CONFIG_URL
                     standbyURLPath:[NSString stringWithFormat:YYK_STANDBY_PAYMENT_CONFIG_URL, YYK_REST_APP_ID]
                         withParams:@{@"appId":YYK_REST_APP_ID, @"channelNo":YYK_CHANNEL_NO, @"pV":YYK_REST_PV}
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKPaymentConfig *config;
        if (respStatus == YYKURLResponseSuccess) {
            self->_loaded = YES;
            
            config = self.response;
            [config setAsCurrentConfig];
            
            DLog(@"Payment config loaded!");
        }
        
        if (handler) {
            handler(respStatus == YYKURLResponseSuccess, config);
        }
    }];
    return ret;
}
@end
