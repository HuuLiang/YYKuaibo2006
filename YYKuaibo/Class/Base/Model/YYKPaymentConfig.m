//
//  YYKPaymentConfig.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPaymentConfig.h"

static NSString *const kPaymentConfigKeyName = @"yykuaibo_payment_config_key_name";

@implementation YYKWeChatPaymentConfig

//+ (instancetype)defaultConfig {
//    YYKWeChatPaymentConfig *config = [[self alloc] init];
//    config.appId = @"wx4af04eb5b3dbfb56";
//    config.mchId = @"1281148901";
//    config.signKey = @"hangzhouquba20151112qwertyuiopas";
//    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWx.json";
//    return config;
//}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.appId forKey:@"appId"];
    [dicRep safelySetObject:self.mchId forKey:@"mchId"];
    [dicRep safelySetObject:self.signKey forKey:@"signKey"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    YYKWeChatPaymentConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@implementation YYKAlipayConfig

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.partner forKey:@"partner"];
    [dicRep safelySetObject:self.seller forKey:@"seller"];
    [dicRep safelySetObject:self.productInfo forKey:@"productInfo"];
    [dicRep safelySetObject:self.privateKey forKey:@"privateKey"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    YYKAlipayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@implementation YYKIAppPayConfig

//+ (instancetype)defaultConfig {
//    YYKIAppPayConfig *config = [[self alloc] init];
//    config.appid = @"3004262770";
//    config.privateKey = @"MIICXQIBAAKBgQCAlkSlxfOCLY/6NPA5VaLvlJjKByjUk2HRGxXDMCZhxucckfvY2yJ0eInTKoqVmkof3+Sp22TNlAdfsMFbsw/9qyHalRclfjhXlKzjurXtGGZ+7uDZGIHM3BV492n1gSbWMAFZE7l5tNPiANkxFjfid7771S3vYB7lthaEcvgRmwIDAQABAoGAMG/qdgOmIcBl/ttYLlDK6rKwB1JBGCpYa3tnbDpECwrw3ftDwkFxriwFxuy8fXQ8PduJ+E3zn9kGGg6sF43RFLVNlEwJMZXWXj0tA1rtbk56vbISXzK+/McDqfhk89abdvdS1HngXRXsYZSFSwt67IwsLRPNCz5vYkS+56kLckkCQQC8IF5zbr+9zLRoUP5H7URNvvYceUHB500skyVfB/kE2KqfP9NCwt7OlTaZG0iFOqSGtG1bqXawiGuTzk+bxvd/AkEArvq/p0dBv00OVFeo7j/OZ2d/usAYSTGCWcGib7vb8xlXHvWkwKSR2priG2vTTNlx7K2r35YheyQcfjV0G4HT5QJBALEF8HrEmw7ZomWK2UwLezuBVwuCGpuAsMEiEYdz9CJYU22Y3I20234fMIov/zTG8uyCuWkIdNQ2+qvR9l1Kg7cCQQCEKAp8cwsrSy2ZciO63iIsYzVLfS5aibQjymW+8inrb6YnUew/O4yViQlhII0Uq96pnXoEgsWC1gFXKVQqOmIpAkBtljLpXAoLNGku5cvGpZycAck9Mbwz4tNzixf4Q/eCuLH6rmUcoNI9q5zQjp8GSITN/7PyzZ+Mw3TahCysC5fl";
//    config.waresid = @(1);
//    config.supportPayTypes = @(YYKIAppPayTypeWeChat);
//    return config;
//}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    YYKIAppPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.appid forKey:@"appid"];
    [dicRep safelySetObject:self.privateKey forKey:@"privateKey"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    [dicRep safelySetObject:self.waresid forKey:@"waresid"];
    [dicRep safelySetObject:self.supportPayTypes forKey:@"supportPayTypes"];
    return dicRep;
}
@end

@implementation YYKVIAPayConfig

+ (instancetype)defaultConfig {
    YYKVIAPayConfig *config = [[self alloc] init];
    //config.packageId = @"5361";
    config.supportPayTypes = @(YYKSubPayTypeAlipay);
    return config;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
//    [dicRep safelySetObject:self.packageId forKey:@"packageId"];
    [dicRep safelySetObject:self.supportPayTypes forKey:@"supportPayTypes"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    YYKVIAPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@implementation YYKSPayConfig

+ (instancetype)defaultConfig {
    YYKSPayConfig *config = [[self alloc] init];
    config.mchId = @"5712000010";
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWft.json";
    config.signKey = @"5afe11de0df374f5f78839db1904ff0d";
    return config;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.mchId forKey:@"mchId"];
    [dicRep safelySetObject:self.signKey forKey:@"signKey"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    YYKSPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@interface YYKPaymentConfigRespCode : NSObject
@property (nonatomic) NSNumber *value;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *message;
@end

@implementation YYKPaymentConfigRespCode

@end

static YYKPaymentConfig *_shardConfig;

@interface YYKPaymentConfig ()
@property (nonatomic) YYKPaymentConfigRespCode *code;
@end

@implementation YYKPaymentConfig

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shardConfig = [[self alloc] init];
        [_shardConfig loadCachedConfig];
    });
    return _shardConfig;
}

- (NSNumber *)success {
    return self.code.value.unsignedIntegerValue == 100 ? @(1) : (0);
}

- (NSString *)resultCode {
    return self.code.value.stringValue;
}

- (Class)codeClass {
    return [YYKPaymentConfigRespCode class];
}

- (Class)weixinInfoClass {
    return [YYKWeChatPaymentConfig class];
}

- (Class)alipayInfoClass {
    return [YYKAlipayConfig class];
}

- (Class)iappPayInfoClass {
    return [YYKIAppPayConfig class];
}

- (Class)syskPayInfoClass {
    return [YYKVIAPayConfig class];
}

- (Class)wftPayInfoClass {
    return [YYKSPayConfig class];
}

- (void)loadCachedConfig {
    NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentConfigKeyName];
//    NSDictionary *weixinInfo = configDic[@"weixinInfo"];
//    if (weixinInfo) {
//        self.weixinInfo = [YYKWeChatPaymentConfig configFromDictionary:weixinInfo];
//    }
//    NSDictionary *alipayInfo = configDic[@"alipayInfo"];
//    if (alipayInfo) {
//        self.alipayInfo = [YYKAlipayConfig configFromDictionary:alipayInfo];
//    }
//    NSDictionary *iappPayInfo = configDic[@"iappPayInfo"];
//    if (iappPayInfo) {
//        self.iappPayInfo = [YYKIAppPayConfig configFromDictionary:iappPayInfo];
//    }
    
    NSDictionary *syskPayInfo = configDic[@"syskPayInfo"];
    if (syskPayInfo) {
        self.syskPayInfo = [YYKVIAPayConfig configFromDictionary:syskPayInfo];
    }
    
    NSDictionary *wftPayInfo = configDic[@"wftPayInfo"];
    if (wftPayInfo) {
        self.wftPayInfo = [YYKSPayConfig configFromDictionary:wftPayInfo];
    }
    
    if (!self.syskPayInfo && !self.wftPayInfo) {
        self.syskPayInfo = [YYKVIAPayConfig defaultConfig];
        self.wftPayInfo = [YYKSPayConfig defaultConfig];
    }
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [[NSMutableDictionary alloc] init];
//    [dicRep safelySetObject:[self.weixinInfo dictionaryRepresentation] forKey:@"weixinInfo"];
//    [dicRep safelySetObject:[self.alipayInfo dictionaryRepresentation] forKey:@"alipayInfo"];
//    [dicRep safelySetObject:[self.iappPayInfo dictionaryRepresentation] forKey:@"iappPayInfo"];
    [dicRep safelySetObject:[self.syskPayInfo dictionaryRepresentation] forKey:@"syskPayInfo"];
    [dicRep safelySetObject:[self.wftPayInfo dictionaryRepresentation] forKey:@"wftPayInfo"];
    return dicRep;
}

- (void)setAsCurrentConfig {
    YYKPaymentConfig *currentConfig = [[self class] sharedConfig];
    currentConfig.syskPayInfo = self.syskPayInfo;
    currentConfig.wftPayInfo = self.wftPayInfo;
    
    [[NSUserDefaults standardUserDefaults] setObject:[self dictionaryRepresentation] forKey:kPaymentConfigKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
