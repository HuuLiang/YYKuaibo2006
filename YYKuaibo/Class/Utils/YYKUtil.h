//
//  YYKUtil.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPaymentInfoKeyName;

@class YYKPaymentInfo;
@class YYKVideo;

@interface YYKUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

+ (NSArray<YYKPaymentInfo *> *)allPaymentInfos;
+ (NSArray<YYKPaymentInfo *> *)payingPaymentInfos;
+ (NSArray<YYKPaymentInfo *> *)paidNotProcessedPaymentInfos;
+ (YYKPaymentInfo *)successfulPaymentInfo;

+ (BOOL)isPaid;

+ (NSString *)accessId;
+ (NSString *)userId;
+ (NSString *)deviceName;
+ (NSString *)appVersion;

+ (NSString *)paymentReservedData;

+ (NSString *)cachedImageSizeString;

@end
