//
//  YYKNetworkInfo.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKNetworkInfo.h"
#import <AFNetworkReachabilityManager.h>

@import CoreTelephony;

@interface YYKNetworkInfo ()
@property (nonatomic,retain,readonly) CTTelephonyNetworkInfo *networkInfo;
@end

@implementation YYKNetworkInfo
@synthesize networkInfo = _networkInfo;

DefineLazyPropertyInitialization(CTTelephonyNetworkInfo, networkInfo)

+ (instancetype)sharedInfo {
    static YYKNetworkInfo *_sharedInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[self alloc] init];
    });
    return _sharedInfo;
}

- (YYKNetworkStatus)networkStatus {
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusNotReachable) {
        return YYKNetworkStatusNotReachable;
    } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        return YYKNetworkStatusWiFi;
    } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        NSString *radioAccess = self.networkInfo.currentRadioAccessTechnology;
        if ([radioAccess isEqualToString:CTRadioAccessTechnologyGPRS]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyEdge]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return YYKNetworkStatus2G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyWCDMA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSDPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSUPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return YYKNetworkStatus3G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyLTE]) {
            return YYKNetworkStatus4G;
        }
    }
    return YYKNetworkStatusUnknown;
}
@end
