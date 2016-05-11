//
//  YYKNetworkInfo.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YYKNetworkStatus) {
    YYKNetworkStatusUnknown = -1,
    YYKNetworkStatusNotReachable = 0,
    YYKNetworkStatusWiFi = 1,
    YYKNetworkStatus2G = 2,
    YYKNetworkStatus3G = 3,
    YYKNetworkStatus4G = 4
};

@interface YYKNetworkInfo : NSObject

@property (nonatomic,readonly) YYKNetworkStatus networkStatus;

+ (instancetype)sharedInfo;

@end
