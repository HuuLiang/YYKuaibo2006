//
//  QBNetworkInfo.m
//  QBNetworking
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "QBNetworkInfo.h"
#import "AFNetworking.h"
#import "RACEXTScope.h"
#import "QBDefines.h"

@import SystemConfiguration;
@import CoreTelephony;

@interface QBNetworkInfo ()
@property (nonatomic,retain,readonly) CTTelephonyNetworkInfo *networkInfo;
@end

@implementation QBNetworkInfo
@synthesize networkInfo = _networkInfo;

- (CTTelephonyNetworkInfo *)networkInfo {
    if (_networkInfo) {
        return _networkInfo;
    }
    
    _networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    return _networkInfo;
}

+ (instancetype)sharedInfo {
    static QBNetworkInfo *_sharedInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[self alloc] init];
    });
    return _sharedInfo;
}

- (void)startMonitoring {
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        BOOL reachable = NO;
        if (status == AFNetworkReachabilityStatusReachableViaWWAN
            || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            reachable = YES;
        }
        QBSafelyCallBlock(self.reachabilityChangedAction, reachable);
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (QBNetworkStatus)networkStatus {
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusNotReachable) {
        return QBNetworkStatusNotReachable;
    } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        return QBNetworkStatusWiFi;
    } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        NSString *radioAccess = self.networkInfo.currentRadioAccessTechnology;
        if ([radioAccess isEqualToString:CTRadioAccessTechnologyGPRS]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyEdge]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return QBNetworkStatus2G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyWCDMA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSDPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSUPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return QBNetworkStatus3G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyLTE]) {
            return QBNetworkStatus4G;
        }
    }
    return QBNetworkStatusUnknown;
}

- (NSString *)carriarName {
    return self.networkInfo.subscriberCellularProvider.carrierName;
}
@end
