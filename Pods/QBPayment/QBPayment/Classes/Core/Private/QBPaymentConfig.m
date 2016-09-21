//
//  QBPaymentConfig.m
//  QBuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "QBPaymentConfig.h"
#import "NSObject+DictionaryRepresentation.h"

static QBPaymentConfig *_shardConfig;
static NSString *const kPaymentConfigKeyName = @"qbpayment_config_key_name";

@interface QBPaymentConfig ()
@property (nonatomic) NSNumber *code;
@property (nonatomic,retain) NSDictionary *paymentTypeMapping;
@end

@implementation QBPaymentConfig

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
    QBPaymentConfig *defaultConfig = [[self alloc] init];
    
    defaultConfig.payConfig = [[QBPaymentConfigSummary alloc] init];
    defaultConfig.payConfig.wechat = kYYKVIAPayConfigName;
    defaultConfig.payConfig.alipay = kYYKVIAPayConfigName;
    
    defaultConfig.configDetails = [[QBPaymentConfigDetail alloc] init];
    defaultConfig.configDetails.viaPayConfig = [QBVIAPayConfig defaultConfig];
    
    return defaultConfig;
}

- (NSDictionary *)paymentTypeMapping {
    if (_paymentTypeMapping) {
        return _paymentTypeMapping;
    }
    
    _paymentTypeMapping = @{kYYKVIAPayConfigName:@(QBPayTypeVIAPay),
                            kYYKIAppPayConfigName:@(QBPayTypeIAppPay),
                            kYYKMingPayConfigName:@(QBPayTypeMingPay),
                            kYYKSPayConfigName:@(QBPayTypeSPay),
                            kYYKHTPayConfigName:@(QBPayTypeHTPay),
                            kYYKDXTXPayConfigName:@(QBPayTypeDXTXPay),
							kYYKWeiYingConfigName:@(QBPayTypeWeiYingPay)};
    return _paymentTypeMapping;
}

- (QBPayType)wechatPaymentType {
    if (self.payConfig.wechat) {
        NSNumber *type = self.paymentTypeMapping[self.payConfig.wechat];
        return type ? type.unsignedIntegerValue : QBPayTypeNone;
    }
    return QBPayTypeNone;
}

- (QBPayType)alipayPaymentType {
    if (self.payConfig.alipay) {
        NSNumber *type = self.paymentTypeMapping[self.payConfig.alipay];
        return type ? type.unsignedIntegerValue : QBPayTypeNone;
    }
    return QBPayTypeNone;
}

- (QBPayType)qqPaymentType {
    if (self.payConfig.qqpay) {
        NSNumber *type = self.paymentTypeMapping[self.payConfig.qqpay];
        return type ? type.unsignedIntegerValue : QBPayTypeNone;
    }
    return QBPayTypeNone;
}

- (NSNumber *)success {
    return _code.unsignedIntegerValue == 100 ? @(YES) : @(NO);
}

- (NSString *)resultCode {
    return _code.stringValue;
}

- (Class)payConfigClass {
    return [QBPaymentConfigSummary class];
}

- (Class)configDetailsClass {
    return [QBPaymentConfigDetail class];
}

- (void)setAsCurrentConfig {
    QBPaymentConfig *currentConfig = [[self class] sharedConfig];
    currentConfig.payConfig = self.payConfig;
    currentConfig.configDetails = self.configDetails;
    
    [[NSUserDefaults standardUserDefaults] setObject:[self dictionaryRepresentationWithEncryptBlock:nil] forKey:kPaymentConfigKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
