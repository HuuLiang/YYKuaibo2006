//
//  YYKSystemConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKSystemConfigModel.h"

@implementation YYKSystemConfigResponse

- (Class)confisElementClass {
    return [YYKSystemConfig class];
}

@end

@implementation YYKSystemConfigModel

+ (instancetype)sharedModel {
    static YYKSystemConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[YYKSystemConfigModel alloc] init];
    });
    return _sharedModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _halfPayLaunchSeq = -1;
        _halfPayLaunchDelay = -1;
    }
    return self;
}

+ (Class)responseClass {
    return [YYKSystemConfigResponse class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)fetchSystemConfigWithCompletionHandler:(YYKFetchSystemConfigCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:YYK_SYSTEM_CONFIG_URL
                         standbyURLPath:YYK_STANDBY_SYSTEM_CONFIG_URL
                             withParams:nil
                        responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (respStatus == YYKURLResponseSuccess) {
            YYKSystemConfigResponse *resp = self.response;
            
            [resp.confis enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                YYKSystemConfig *config = obj;
                
                if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PAY_AMOUNT]) {
                    self.payAmount = config.value.doubleValue / 100.;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PAY_IMG]) {
                    self.paymentImage = config.value;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PAYMENT_TOP_IMAGE]) {
                    self.channelTopImage = config.value;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_STARTUP_INSTALL]) {
                    self.startupInstall = config.value;
                    self.startupPrompt = config.memo;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_TOP_IMAGE]) {
                    self.spreadTopImage = config.value;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_URL]) {
                    self.spreadURL = config.value;
//                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_LEFT_IMAGE]) {
//                    self.spreadLeftImage = config.value;
//                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_LEFT_URL]) {
//                    self.spreadLeftUrl = config.value;
//                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_RIGHT_IMAGE]) {
//                    self.spreadRightImage = config.value;
//                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_RIGHT_URL]) {
//                    self.spreadRightUrl = config.value;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_CONTACT]) {
                    self.contact = config.value;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_HALF_PAY_SEQ]) {
                    self.halfPayLaunchSeq = config.value.integerValue;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_HALF_PAY_DELAY]) {
                    self.halfPayLaunchDelay = config.value.integerValue;
                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_HALF_PAY_NOTIFICATION]) {
                    self.halfPayLaunchNotification = config.value;
                }
            }];
            
            _loaded = YES;
        }
        
        if (handler) {
            handler(respStatus==YYKURLResponseSuccess);
        }
    }];
    return success;
}

- (double)payAmount {
    if (self.halfPayLaunchSeq >= 0 && [YYKUtil launchSeq] >= self.halfPayLaunchSeq) {
        return _payAmount / 2;
    } else {
        return _payAmount;
    }
}
@end
