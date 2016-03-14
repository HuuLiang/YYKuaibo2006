//
//  JQKUtil.h
//  JQKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPaymentInfoKeyName;

@class JQKPaymentInfo;
@class JQKVideo;

@interface JQKUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

+ (NSArray<JQKPaymentInfo *> *)allPaymentInfos;
+ (NSArray<JQKPaymentInfo *> *)payingPaymentInfos;
+ (NSArray<JQKPaymentInfo *> *)paidNotProcessedPaymentInfos;
+ (JQKPaymentInfo *)successfulPaymentInfo;

+ (BOOL)isPaid;

+ (NSString *)accessId;
+ (NSString *)userId;
+ (NSString *)deviceName;
+ (NSString *)appVersion;

+ (NSString *)paymentReservedData;

@end
