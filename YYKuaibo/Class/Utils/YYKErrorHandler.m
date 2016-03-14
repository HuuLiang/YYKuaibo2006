//
//  JQKErrorHandler.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "JQKErrorHandler.h"
#import "JQKURLRequest.h"

NSString *const kNetworkErrorNotification = @"JQKNetworkErrorNotification";
NSString *const kNetworkErrorCodeKey = @"JQKNetworkErrorCodeKey";
NSString *const kNetworkErrorMessageKey = @"JQKNetworkErrorMessageKey";

@implementation JQKErrorHandler

+ (instancetype)sharedHandler {
    static JQKErrorHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[JQKErrorHandler alloc] init];
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
    JQKURLResponseStatus resp = (JQKURLResponseStatus)(((NSNumber *)userInfo[kNetworkErrorCodeKey]).unsignedIntegerValue);
    
    if (resp == JQKURLResponseFailedByInterface) {
        [[JQKHudManager manager] showHudWithText:@"获取网络数据失败"];
    } else if (resp == JQKURLResponseFailedByNetwork) {
        [[JQKHudManager manager] showHudWithText:@"网络错误，请检查网络连接！"];
    }
    
}
@end
