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
#import "YYKVideo.h"

NSString *const kPaymentInfoKeyName = @"yykuaibov_paymentinfo_keyname";

static NSString *const kRegisterKeyName = @"yykuaibov_register_keyname";
static NSString *const kUserAccessUsername = @"yykuaibov_user_access_username";
static NSString *const kUserAccessServicename = @"yykuaibov_user_access_service";

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

+ (YYKPaymentInfo *)successfulPaymentInfo {
    return [self.allPaymentInfos bk_match:^BOOL(id obj) {
        YYKPaymentInfo *paymentInfo = obj;
        if (paymentInfo.paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
            return YES;
        }
        return NO;
    }];
}

+ (BOOL)isPaid {
    return [self successfulPaymentInfo] != nil;
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
@end
