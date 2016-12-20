//
//  YYKUtil.m
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "YYKUtil.h"
#import <SFHFKeychainUtils.h>
#import <sys/sysctl.h>
#import "NSDate+Utilities.h"
#import "YYKSpreadBannerViewController.h"
#import "YYKAppSpreadBannerModel.h"
#import "YYKApplicationManager.h"
#import "YYKSystemConfigModel.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

static NSString *const kRegisterKeyName = @"yykuaibov_register_keyname";
static NSString *const kUserAccessUsername = @"yykuaibov_user_access_username";
static NSString *const kUserAccessServicename = @"yykuaibov_user_access_service";
static NSString *const kLaunchSeqKeyName = @"yykuaibov_launchseq_keyname";

static NSString *const kImageTokenKeyName = @"safiajfoaiefr$^%^$E&&$*&$*";
static NSString *const kImageTokenCryptPassword = @"wafei@#$%^%$^$wfsssfsf";

@implementation YYKUtil

+ (NSString *)accessId {
    NSString *accessIdInKeyChain = [SFHFKeychainUtils getPasswordForUsername:kUserAccessUsername andServiceName:kUserAccessServicename error:nil];
    if (accessIdInKeyChain) {
        return accessIdInKeyChain;
    }
    
    accessIdInKeyChain = [NSUUID UUID].UUIDString.md5;
    [SFHFKeychainUtils storeUsername:kUserAccessUsername andPassword:accessIdInKeyChain forServiceName:kUserAccessServicename updateExisting:YES error:nil];
    return accessIdInKeyChain;
}

+ (BOOL)isRegistered {
    return [self userId] != nil;
}

+ (void)setRegisteredWithUserId:(NSString *)userId {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray<YYKPaymentInfo *> *)allPaymentInfos {
    return [QBPaymentInfo allPaymentInfos];
}

+ (NSArray<YYKPaymentInfo *> *)payingPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus == QBPayStatusPaying;
    }];
}

+ (NSArray<YYKPaymentInfo *> *)paidNotProcessedPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus == QBPayStatusNotProcessed;
    }];
}

+ (NSArray<YYKPaymentInfo *> *)allSuccessfulPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        if (paymentInfo.paymentResult == QBPayResultSuccess) {
            return YES;
        }
        return NO;
    }];
}

+ (NSArray<YYKPaymentInfo *> *)allUnsuccessfulPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        if (paymentInfo.paymentResult != QBPayResultSuccess) {
            return YES;
        }
        return NO;
    }];
}
//+ (YYKPaymentInfo *)successfulPaymentInfo {
//    return [self.allPaymentInfos bk_match:^BOOL(id obj) {
//        YYKPaymentInfo *paymentInfo = obj;
//        if (paymentInfo.paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
//            return YES;
//        }
//        return NO;
//    }];
//}

+ (BOOL)isVIP {
//    return YES;
    YYKPaymentInfo *vipPaymentInfo = [[self allSuccessfulPaymentInfos] bk_match:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.payPointType == QBPayPointTypeVIP
        || paymentInfo.payPointType == QBPayPointTypeSVIP;
    }];
    return vipPaymentInfo != nil;
}

+ (BOOL)isSVIP {
    YYKPaymentInfo *vipPaymentInfo = [[self allSuccessfulPaymentInfos] bk_match:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.payPointType == QBPayPointTypeSVIP;
    }];
    return vipPaymentInfo != nil;
}

+ (BOOL)isNoVIP {
    return ![self isVIP] && ![self isSVIP];
}

+ (BOOL)isAnyVIP {
    return [self isVIP] || [self isSVIP];
}

+ (BOOL)isAllVIPs {
    return [self isVIP] && [self isSVIP];
}
//+ (BOOL)isPaid {
//    return [self successfulPaymentInfo] != nil;
//}

+ (NSString *)imageToken {
    NSString *imageToken = [[NSUserDefaults standardUserDefaults] objectForKey:kImageTokenKeyName];
    if (!imageToken) {
        return nil;
    }
    
    return [imageToken decryptedStringWithPassword:kImageTokenCryptPassword];
}

+ (void)setImageToken:(NSString *)imageToken {
    if (imageToken) {
        imageToken = [imageToken encryptedStringWithPassword:kImageTokenCryptPassword];
        [[NSUserDefaults standardUserDefaults] setObject:imageToken forKey:kImageTokenKeyName];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kImageTokenKeyName];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRegisterKeyName];
}

+ (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

+ (YYKDeviceType)deviceType {
    NSString *deviceName = [self deviceName];
    if ([deviceName rangeOfString:@"iPhone3,"].location == 0) {
        return YYKDeviceType_iPhone4;
    } else if ([deviceName rangeOfString:@"iPhone4,"].location == 0) {
        return YYKDeviceType_iPhone4S;
    } else if ([deviceName rangeOfString:@"iPhone5,1"].location == 0 || [deviceName rangeOfString:@"iPhone5,2"].location == 0) {
        return YYKDeviceType_iPhone5;
    } else if ([deviceName rangeOfString:@"iPhone5,3"].location == 0 || [deviceName rangeOfString:@"iPhone5,4"].location == 0) {
        return YYKDeviceType_iPhone5C;
    } else if ([deviceName rangeOfString:@"iPhone6,"].location == 0) {
        return YYKDeviceType_iPhone5S;
    } else if ([deviceName rangeOfString:@"iPhone7,1"].location == 0) {
        return YYKDeviceType_iPhone6P;
    } else if ([deviceName rangeOfString:@"iPhone7,2"].location == 0) {
        return YYKDeviceType_iPhone6;
    } else if ([deviceName rangeOfString:@"iPhone8,1"].location == 0) {
        return YYKDeviceType_iPhone6S;
    } else if ([deviceName rangeOfString:@"iPhone8,2"].location == 0) {
        return YYKDeviceType_iPhone6SP;
    } else if ([deviceName rangeOfString:@"iPhone8,4"].location == 0) {
        return YYKDeviceType_iPhoneSE;
    } else if ([deviceName rangeOfString:@"iPad"].location == 0) {
        return YYKDeviceType_iPad;
    } else {
        return YYKDeviceTypeUnknown;
    }
}

+ (BOOL)isIpad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


+ (NSString *)appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)paymentReservedData {
    return [NSString stringWithFormat:@"%@$%@", YYK_REST_APP_ID, YYK_CHANNEL_NO];
}

+ (NSString *)cachedImageSizeString {
    NSUInteger size = [[SDImageCache sharedImageCache] getSize];
    NSUInteger k = size / 1024;
    if (k >= 1024) {
        return [NSString stringWithFormat:@"%.1f M", size / (1024. * 1024.)];
    } else if (k > 0) {
        return [NSString stringWithFormat:@"%.1f K", size / 1024.];
    } else {
        return [NSString stringWithFormat:@"%ld B", (unsigned long)size];
    }
}

+ (void)callPhoneNumber:(NSString *)phoneNum {
    [UIAlertView bk_showAlertViewWithTitle:nil
                                   message:[NSString stringWithFormat:@"拨打热线电话：%@", phoneNum]
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"确认"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex)
    {
        if (buttonIndex == 1) {
            NSString *phoneUrl = [NSString stringWithFormat:@"tel://%@", phoneNum];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneUrl]];
        }
    }];
}

+ (void)contactCustomerService {
    NSString *contactScheme = [YYKSystemConfigModel sharedModel].contactScheme;
    NSString *contactName = [YYKSystemConfigModel sharedModel].contactName;
    
    if (contactScheme.length == 0) {
        return ;
    }
    
    [UIAlertView bk_showAlertViewWithTitle:nil
                                   message:[NSString stringWithFormat:@"是否联系客服%@？", contactName ?: @""]
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"确认"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == 1) {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contactScheme]];
         }
     }];
}

+ (NSUInteger)launchSeq {
    NSNumber *launchSeq = [[NSUserDefaults standardUserDefaults] objectForKey:kLaunchSeqKeyName];
    return launchSeq.unsignedIntegerValue;
}

+ (void)accumateLaunchSeq {
    NSUInteger launchSeq = [self launchSeq];
    [[NSUserDefaults standardUserDefaults] setObject:@(launchSeq+1) forKey:kLaunchSeqKeyName];
}

+ (void)showSpreadBanner {
#ifndef DEBUG
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *spreads = [YYKAppSpreadBannerModel sharedModel].fetchedSpreads;
        NSArray *allInstalledAppIds = [[YYKApplicationManager defaultManager] allInstalledAppIdentifiers];
        NSArray *uninstalledSpreads = [spreads bk_select:^BOOL(id obj) {
            return ![allInstalledAppIds containsObject:[obj specialDesc]];
        }];
        
        if (uninstalledSpreads.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                YYKSpreadBannerViewController *spreadVC = [[YYKSpreadBannerViewController alloc] initWithSpreads:uninstalledSpreads];
                [spreadVC showInViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
            });
        }
    });
#endif
}

+ (void)requestAllInstalledAppIdsWithCompletionHandler:(void (^)(NSArray<NSString *> *))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *allInstalledAppIds = [[YYKApplicationManager defaultManager] allInstalledAppIdentifiers];
        dispatch_async(dispatch_get_main_queue(), ^{
            SafelyCallBlock(completionHandler, allInstalledAppIds);
        });
    });
}

+ (void)checkAppInstalledWithBundleId:(NSString *)bundleId completionHandler:(void (^)(BOOL))handler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL installed = [[[YYKApplicationManager defaultManager] allInstalledAppIdentifiers] bk_any:^BOOL(id obj) {
            return [bundleId isEqualToString:obj];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(installed);
            }
        });
    });
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
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

+ (UIViewController *)currentVisibleViewController {
    UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *selectedVC = tabBarController.selectedViewController;
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = (UINavigationController *)selectedVC;
        return navVC.visibleViewController;
    }
    return selectedVC;
}
//+ (void)checkAppsInstalledWithBundleIds:(NSArray<NSString *> *)bundleIds completionHandler:(void (^)(NSArray *))handler {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSArray *allInstalledAppIds = [[YYKApplicationManager defaultManager] allInstalledAppIdentifiers];
//        NSArray *installedAppIds = [allInstalledAppIds bk_select:^BOOL(id obj) {
//            return [allInstalledAppIds containsObject:obj];
//        }];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (handler) {
//                handler(installedAppIds);
//            }
//        });
//    };
//}

+ (NSUInteger)currentTabPageIndex {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        return tabVC.selectedIndex;
    }
    return 0;
}

+ (NSUInteger)currentSubTabPageIndex {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        if ([tabVC.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVC = (UINavigationController *)tabVC.selectedViewController;
            if ([navVC.visibleViewController isKindOfClass:[YYKBaseViewController class]]) {
                YYKBaseViewController *baseVC = (YYKBaseViewController *)navVC.visibleViewController;
                return [baseVC currentIndex];
            }
        }
    }
    return NSNotFound;
}

+ (NSString *)currentTimeString {
    NSDateFormatter *fomatter =[[NSDateFormatter alloc] init];
    [fomatter setDateFormat:kDefaultDateFormat];
    return [fomatter stringFromDate:[NSDate date]];
}

//+ (void)setDefaultPrice {
//    [YYKSystemConfigModel sharedModel].payAmount = 45;
//    [YYKSystemConfigModel sharedModel].svipPayAmount = 71;
//}
+ (NSString *)getStandByUrlPathWithOriginalUrl:(NSString *)url params:(id)params {
    NSMutableString *standbyUrl = [NSMutableString stringWithString:YYK_STANDBY_BASE_URL];
    [standbyUrl appendString:[url substringToIndex:url.length-4]];
    [standbyUrl appendFormat:@"-%@-%@",YYK_REST_APP_ID,YYK_REST_PV];
    if (params) {
        if ([params isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)params;
            for (int i = 0; i<[dic allKeys].count; i++) {
                [standbyUrl appendFormat:@"-%@",[dic allValues][i]];
            }
        }else if ([params isKindOfClass:[NSArray class]]){
            NSArray *para = (NSArray *)params;
            for (int i = 0; i< para.count; i++) {
                [standbyUrl appendFormat:@"-%@",para[i]];
            }
        }
    }
    [standbyUrl appendString:@".json"];
    
    return standbyUrl;
}

#pragma mark - 视频链接加密
//签名原始字符串S = key + url_encode(path) + T 。斜线 / 不编码。

//签名SIGN = md5(S).to_lower()，to_lower指将字符串转换为小写；

+ (NSString *)encodeVideoUrlWithVideoUrlStr:(NSString *)videoUrlStr {
    NSString *signKey = [YYKSystemConfigModel sharedModel].videoSignKey;
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)timeInterval + (long)[YYKSystemConfigModel sharedModel].expireTime];
    NSString *expireTime = [NSString stringWithFormat:@"%x",[timeStr intValue]];
    
    NSMutableString *newVideoUrl = [[NSMutableString alloc] init];
    [newVideoUrl appendString:[videoUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableString *signString = [[NSMutableString alloc] init];
    [signString appendString:signKey];
    [signString appendString:[self getVideoUrlPath:videoUrlStr]];
    [signString appendString:expireTime];
    
    NSString *signCode = [NSMutableString stringWithFormat:@"%@", [signString.md5 lowercaseString]];
    
    [newVideoUrl appendFormat:@"?sign=%@&t=%@",signCode,expireTime];
    
    return newVideoUrl;
}

+ (NSString *)getVideoUrlPath:(NSString *)videoUrl {
    NSString * string1 = [[videoUrl componentsSeparatedByString:@".com"] lastObject];
    NSString * stirng2 = [[string1 componentsSeparatedByString:@"?"] firstObject];
    NSString *encodingString = [stirng2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodingString;
}

@end
