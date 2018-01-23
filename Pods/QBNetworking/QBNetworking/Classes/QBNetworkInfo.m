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
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netdb.h> 

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

- (NSString *)ipAddress {
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (NSString *)ipAddressOfHost:(NSString *)hostName {
    struct hostent *host_entry = gethostbyname(hostName.UTF8String);
    char *buff;
    buff = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
    NSString *ipAddress = [NSString stringWithUTF8String:buff];
    
    return ipAddress;
}
@end
