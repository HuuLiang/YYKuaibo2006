//
//  YYKLocalNotificationManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKLocalNotificationManager : NSObject

+ (instancetype)sharedManager;
- (void)scheduleLocalNotification:(NSString *)notification withDelay:(NSTimeInterval)delay;
- (void)scheduleRepeatNotification:(NSString *)notification withTimes:(NSArray<NSString *> *)times;
- (void)cancelAllNotifications;

@end
