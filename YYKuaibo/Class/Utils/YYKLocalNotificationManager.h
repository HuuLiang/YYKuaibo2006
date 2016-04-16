//
//  YYKLocalNotificationManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKLocalNotificationManager : NSObject

@property (nonatomic,readonly) NSArray<NSString *> *repeatTimes;

+ (instancetype)sharedManager;
- (void)scheduleLocalNotificationInEnteringBackground;
- (void)scheduleLocalNotification:(NSString *)notification withDelay:(NSTimeInterval)delay;

- (void)scheduleRepeatNotification;
- (void)scheduleRepeatNotification:(NSString *)notification withTimes:(NSArray<NSString *> *)times;
- (void)cancelAllNotifications;

@end
