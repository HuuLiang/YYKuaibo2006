//
//  YYKErrorHandler.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKErrorHandler.h"
#import "YYKURLRequest.h"

NSString *const kNetworkErrorNotification = @"YYKNetworkErrorNotification";
NSString *const kNetworkErrorCodeKey = @"YYKNetworkErrorCodeKey";
NSString *const kNetworkErrorMessageKey = @"YYKNetworkErrorMessageKey";

@implementation YYKErrorHandler

+ (instancetype)sharedHandler {
    static YYKErrorHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[YYKErrorHandler alloc] init];
    });
    return _handler;
}

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkError:) name:kNetworkErrorNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNetworkError:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    YYKURLResponseStatus resp = (YYKURLResponseStatus)(((NSNumber *)userInfo[kNetworkErrorCodeKey]).unsignedIntegerValue);
    
    if (resp == YYKURLResponseFailedByInterface) {
        [[YYKHudManager manager] showHudWithText:@"获取网络数据失败"];
    } else if (resp == YYKURLResponseFailedByNetwork) {
        [[YYKHudManager manager] showHudWithText:@"网络错误，请检查网络连接！"];
    }
    
}
@end
