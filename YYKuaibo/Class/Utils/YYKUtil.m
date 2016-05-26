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
#import "YYKPaymentInfo.h"
#import "YYKSpreadBannerViewController.h"
#import "YYKAppSpreadBannerModel.h"
#import "YYKApplicationManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

NSString *const kPaymentInfoKeyName = @"yykuaibov_paymentinfo_keyname";

static NSString *const kRegisterKeyName = @"yykuaibov_register_keyname";
static NSString *const kUserAccessUsername = @"yykuaibov_user_access_username";
static NSString *const kUserAccessServicename = @"yykuaibov_user_access_service";
static NSString *const kLaunchSeqKeyName = @"yykuaibov_launchseq_keyname";

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
    NSArray<NSDictionary *> *paymentInfoArr = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfos = [NSMutableArray array];
    [paymentInfoArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YYKPaymentInfo *paymentInfo = [YYKPaymentInfo paymentInfoFromDictionary:obj];
        [paymentInfos addObject:paymentInfo];
    }];
    return paymentInfos;
}

+ (NSArray<YYKPaymentInfo *> *)payingPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == YYKPaymentStatusPaying;
    }];
}

+ (NSArray<YYKPaymentInfo *> *)paidNotProcessedPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == YYKPaymentStatusNotProcessed;
    }];
}

+ (NSArray<YYKPaymentInfo *> *)allSuccessfulPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        if (paymentInfo.paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
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
    YYKPaymentInfo *vipPaymentInfo = [[self allSuccessfulPaymentInfos] bk_match:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeVIP
        || paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP;
    }];
    return vipPaymentInfo != nil;
}

+ (BOOL)isSVIP {
    YYKPaymentInfo *vipPaymentInfo = [[self allSuccessfulPaymentInfos] bk_match:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        return paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP;
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

+ (NSUInteger)launchSeq {
    NSNumber *launchSeq = [[NSUserDefaults standardUserDefaults] objectForKey:kLaunchSeqKeyName];
    return launchSeq.unsignedIntegerValue;
}

+ (void)accumateLaunchSeq {
    NSUInteger launchSeq = [self launchSeq];
    [[NSUserDefaults standardUserDefaults] setObject:@(launchSeq+1) forKey:kLaunchSeqKeyName];
}

+ (void)showSpreadBanner {
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

@end
