//
//  YYKPaymentConfig.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPaymentConfig.h"

static YYKPaymentConfig *_shardConfig;
static NSString *const kPaymentConfigKeyName = @"yykuaibo_payment_config_key_name";

@interface YYKPaymentConfig ()
@property (nonatomic) NSNumber *code;
@property (nonatomic,retain) NSDictionary *paymentTypeMapping;
@end

@implementation YYKPaymentConfig

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentConfigKeyName];
        _shardConfig = [self objectFromDictionary:configDic withDecryptBlock:nil];
        
        if (!_shardConfig) {
            _shardConfig = [self defaultConfig];
        }
    });
    return _shardConfig;
}

+ (instancetype)defaultConfig {
    YYKPaymentConfig *defaultConfig = [[self alloc] init];
    
    defaultConfig.payConfig = [[YYKPaymentConfigSummary alloc] init];
    defaultConfig.payConfig.wechat = kYYKVIAPayConfigName;
    defaultConfig.payConfig.alipay = kYYKVIAPayConfigName;
    
    defaultConfig.configDetails = [[YYKPaymentConfigDetail alloc] init];
    defaultConfig.configDetails.viaPayConfig = [YYKVIAPayConfig defaultConfig];
    
    return defaultConfig;
}

- (NSDictionary *)paymentTypeMapping {
    if (_paymentTypeMapping) {
        return _paymentTypeMapping;
    }
    
    _paymentTypeMapping = @{kYYKVIAPayConfigName:@(YYKPaymentTypeVIAPay),
                            kYYKIAppPayConfigName:@(YYKPaymentTypeIAppPay),
                            kYYKMingPayConfigName:@(YYKPaymentTypeMingPay),
 //                           kYYKSPayConfigName:@(YYKPaymentTypeSPay),
                            kYYKHTPayConfigName:@(YYKPaymentTypeHTPay),
                            kYYKDXTXPayConfigName:@(YYKPaymentTypeDXTXPay)};
    return _paymentTypeMapping;
}

- (YYKPaymentType)wechatPaymentType {
    if (self.payConfig.wechat) {
        NSNumber *type = self.paymentTypeMapping[self.payConfig.wechat];
        return type ? type.unsignedIntegerValue : YYKPaymentTypeNone;
    }
    return YYKPaymentTypeNone;
}

- (YYKPaymentType)alipayPaymentType {
    if (self.payConfig.alipay) {
        NSNumber *type = self.paymentTypeMapping[self.payConfig.alipay];
        return type ? type.unsignedIntegerValue : YYKPaymentTypeNone;
    }
    return YYKPaymentTypeNone;
}

- (YYKPaymentType)qqPaymentType {
    if (self.payConfig.qqpay) {
        NSNumber *type = self.paymentTypeMapping[self.payConfig.qqpay];
        return type ? type.unsignedIntegerValue : YYKPaymentTypeNone;
    }
    return YYKPaymentTypeNone;
}

- (NSNumber *)success {
    return _code.unsignedIntegerValue == 100 ? @(YES) : @(NO);
}

- (NSString *)resultCode {
    return _code.stringValue;
}

- (Class)payConfigClass {
    return [YYKPaymentConfigSummary class];
}

- (Class)configDetailsClass {
    return [YYKPaymentConfigDetail class];
}

- (void)setAsCurrentConfig {
    YYKPaymentConfig *currentConfig = [[self class] sharedConfig];
    currentConfig.payConfig = self.payConfig;
    currentConfig.configDetails = self.configDetails;
    
    [[NSUserDefaults standardUserDefaults] setObject:[self dictionaryRepresentationWithEncryptBlock:nil] forKey:kPaymentConfigKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
