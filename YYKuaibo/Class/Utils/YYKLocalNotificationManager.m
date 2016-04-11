//
//  YYKLocalNotificationManager.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKLocalNotificationManager.h"

@implementation YYKLocalNotificationManager

+ (instancetype)sharedManager {
    static YYKLocalNotificationManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)scheduleLocalNotification:(NSString *)notification withDelay:(NSTimeInterval)delay {
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    localNoti.alertBody = notification;
    localNoti.fireDate = [NSDate dateWithTimeIntervalSinceNow:delay];
    localNoti.timeZone = [NSTimeZone defaultTimeZone];
    localNoti.applicationIconBadgeNumber = 1;
    localNoti.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
}

- (void)cancelAllNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
@end
