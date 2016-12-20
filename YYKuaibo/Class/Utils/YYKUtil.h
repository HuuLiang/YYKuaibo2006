//
//  YYKUtil.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

+ (NSArray<YYKPaymentInfo *> *)allPaymentInfos;
+ (NSArray<YYKPaymentInfo *> *)payingPaymentInfos;
+ (NSArray<YYKPaymentInfo *> *)paidNotProcessedPaymentInfos;
+ (NSArray<YYKPaymentInfo *> *)allSuccessfulPaymentInfos;
+ (NSArray<YYKPaymentInfo *> *)allUnsuccessfulPaymentInfos;
//+ (YYKPaymentInfo *)successfulPaymentInfo;

//+ (BOOL)isPaid;
+ (BOOL)isNoVIP;
+ (BOOL)isAnyVIP;
+ (BOOL)isAllVIPs;

+ (BOOL)isVIP;
+ (BOOL)isSVIP;

+ (NSString *)imageToken;
+ (void)setImageToken:(NSString *)imageToken;

+ (NSString *)accessId;
+ (NSString *)userId;
+ (NSString *)deviceName;
+ (YYKDeviceType)deviceType;
+ (BOOL)isIpad;
+ (NSString *)appVersion;

+ (NSString *)paymentReservedData;

+ (NSString *)cachedImageSizeString;

+ (void)callPhoneNumber:(NSString *)phoneNum;
+ (void)contactCustomerService;

+ (NSUInteger)launchSeq;
+ (void)accumateLaunchSeq;

+ (void)showSpreadBanner;
+ (void)requestAllInstalledAppIdsWithCompletionHandler:(void (^)(NSArray<NSString *> *))completionHandler;
+ (void)checkAppInstalledWithBundleId:(NSString *)bundleId completionHandler:(void (^)(BOOL))handler;

+ (NSUInteger)currentTabPageIndex;
+ (NSUInteger)currentSubTabPageIndex;
+ (NSString *)getIPAddress;
+ (UIViewController *)currentVisibleViewController;

+ (NSString *)currentTimeString;
//+ (void)setDefaultPrice;
+ (NSString *)getStandByUrlPathWithOriginalUrl:(NSString *)url params:(id)params;
+ (NSString *)encodeVideoUrlWithVideoUrlStr:(NSString *)videoUrlStr;
@end
