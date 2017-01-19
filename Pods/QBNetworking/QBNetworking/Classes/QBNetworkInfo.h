//
//  QBNetworkInfo.h
//  QBNetworking
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QBNetworkStatus) {
    QBNetworkStatusUnknown = -1,
    QBNetworkStatusNotReachable = 0,
    QBNetworkStatusWiFi = 1,
    QBNetworkStatus2G = 2,
    QBNetworkStatus3G = 3,
    QBNetworkStatus4G = 4
};

typedef void (^QBNetworkReachabilityChangedAction)(BOOL reachable);

@interface QBNetworkInfo : NSObject

@property (nonatomic,readonly) QBNetworkStatus networkStatus;
@property (nonatomic,readonly) NSString *carriarName;
@property (nonatomic,readonly) NSString *ipAddress;

@property (nonatomic,copy) QBNetworkReachabilityChangedAction reachabilityChangedAction;

+ (instancetype)sharedInfo;
- (void)startMonitoring;
- (NSString *)ipAddressOfHost:(NSString *)hostName;

@end
