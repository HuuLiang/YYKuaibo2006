//
//  QBPaymentConfigDetail.m
//  QBuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "QBPaymentConfigDetail.h"
#import "QBPaymentConfigSummary.h"
#import "QBPaymentDefines.h"
#import "NSMutableDictionary+SafeCoding.h"

NSString *const kYYKIAppPayConfigName = @"IAPPPAY";
NSString *const kYYKVIAPayConfigName = @"SYSK";
NSString *const kYYKMingPayConfigName = @"MPENG";
NSString *const kYYKSPayConfigName = @"WFT";
NSString *const kYYKHTPayConfigName = @"HAITUN";
NSString *const kYYKWeiYingConfigName = @"WEIYINGSDK";
NSString *const kYYKDXTXPayConfigName = @"DXTX";

@implementation QBPaymentConfigDetail

- (Class)QB_classOfProperty:(NSString *)propName {
    if ([propName isEqualToString:NSStringFromSelector(@selector(iAppPayConfig))]) {
        return [QBIAppPayConfig class];
    } else if ([propName isEqualToString:NSStringFromSelector(@selector(viaPayConfig))]) {
        return [QBVIAPayConfig class];
    } else if ([propName isEqualToString:NSStringFromSelector(@selector(mingPayConfig))]) {
        return [QBMingPayConfig class];
    } else if ([propName isEqualToString:NSStringFromSelector(@selector(spayConfig))]) {
        return [QBSPayConfig class];
    } else if ([propName isEqualToString:NSStringFromSelector(@selector(htpayConfig))]) {
        return [QBHTPayConfig class];
    } else if ([propName isEqualToString:NSStringFromSelector(@selector(weiYingPayConfig))]) {
        return [QBWeiYingPayConfig class];
    } else if ([propName isEqualToString:NSStringFromSelector(@selector(dxtxPayConfig))]) {
        return [QBDXTXPayConfig class];
    }
    return nil;
}

- (NSString *)QB_propertyOfParsing:(NSString *)parsingName {
    if ([parsingName hasSuffix:[@"-" stringByAppendingString:kYYKIAppPayConfigName]]) {
        return NSStringFromSelector(@selector(iAppPayConfig));
    } else if ([parsingName hasSuffix:[@"-" stringByAppendingString:kYYKVIAPayConfigName]]) {
        return NSStringFromSelector(@selector(viaPayConfig));
    } else if ([parsingName hasSuffix:[@"-" stringByAppendingString:kYYKMingPayConfigName]]) {
        return NSStringFromSelector(@selector(mingPayConfig));
    } else if ([parsingName hasSuffix:[@"-" stringByAppendingString:kYYKSPayConfigName]]) {
        return NSStringFromSelector(@selector(spayConfig));
    } else if ([parsingName hasSuffix:[@"-" stringByAppendingString:kYYKHTPayConfigName]]) {
        return NSStringFromSelector(@selector(htpayConfig));
    } else if ([parsingName hasSuffix:[@"-" stringByAppendingString:kYYKWeiYingConfigName]]) {
        return NSStringFromSelector(@selector(weiYingPayConfig));
    } else if ([parsingName hasSuffix:[@"-" stringByAppendingString:kYYKDXTXPayConfigName]]) {
        return NSStringFromSelector(@selector(dxtxPayConfig));
    }
    return nil;
}
@end

@implementation QBIAppPayConfig

+ (instancetype)defaultConfig {
    QBIAppPayConfig *config = [[self alloc] init];
    config.appid = @"3006339410";
    config.privateKey = @"MIICWwIBAAKBgQCHEQCLCZujWicF6ClEgHx4L/OdSHZ1LdKi/mzPOIa4IRfMOS09qDNV3+uK/zEEPu1DgO5Cl1lsm4xpwIiOqdXNRxLE9PUfgRy4syiiqRfofAO7w4VLSG4S0VU5F+jqQzKM7Zgp3blbc5BJ5PtKXf6zP3aCAYjz13HHH34angjg0wIDAQABAoGASOJm3aBoqSSL7EcUhc+j2yNdHaGtspvwj14mD0hcgl3xPpYYEK6ETTHRJCeDJtxiIkwfxjVv3witI5/u0LVbFmd4b+2jZQ848BHGFtZFOOPJFVCylTy5j5O79mEx0nJN0EJ/qadwezXr4UZLDIaJdWxhhvS+yDe0e0foz5AxWmkCQQDhd9U1uUasiMmH4WvHqMfq5l4y4U+V5SGb+IK+8Vi03Zfw1YDvKrgv1Xm1mdzYHFLkC47dhTm7/Ko8k5Kncf89AkEAmVtEtycnSYciSqDVXxWtH1tzsDeIMz/ZlDGXCAdUfRR2ZJ2u2jrLFunoS9dXhSGuERU7laasK0bDT4p0UwlhTwJAVF+wtPsRnI1PxX6xA7WAosH0rFuumax2SFTWMLhGduCZ9HEhX97/sD7V3gSnJWRsDJTasMEjWtrxpdufvPOnDQJAdsYPVGMItJPq5S3n0/rv2Kd11HdOD5NWKsa1mMxEjZN5lrfhoreCb7694W9pI31QWX6+ZUtvcR0fS82KBn3vVQJAa0fESiiDDrovKHBm/aYXjMV5anpbuAa5RJwCqnbjCWleZMwHV+8uUq9+YMnINZQnvi+C62It4BD+KrJn5q4pwg==";
    config.publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCbNQyxdpLeMwE0QMv/dB3Jn1SRqYE/u3QT3ig2uXu4yeaZo4f7qJomudLKKOgpa8+4a2JAPRBSueDpiytR0zN5hRZKImeZAu2foSYkpBqnjb5CRAH7roO7+ervoizg6bhAEx2zlltV9wZKQZ0Di5wCCV+bMSEXkYqfASRplYUvHwIDAQAB";
    config.waresid = @(1);
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyIpay.json";
    config.supportPayTypes = @(QBPaySubTypeWeChat|QBPaySubTypeAlipay);
    return config;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    QBIAppPayConfig *config = [[self alloc] init];
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
    [dicRep safelySetObject:self.publicKey forKey:@"publicKey"];
    return dicRep;
}
@end

@implementation QBVIAPayConfig

+ (instancetype)defaultConfig {
    QBVIAPayConfig *config = [[self alloc] init];
    //config.packageId = @"5361";
    config.supportPayTypes = @(QBPaySubTypeAlipay|QBPaySubTypeWeChat);
    return config;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    //    [dicRep safelySetObject:self.packageId forKey:@"packageId"];
    [dicRep safelySetObject:self.supportPayTypes forKey:@"supportPayTypes"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    QBVIAPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@implementation QBSPayConfig

//+ (instancetype)defaultConfig {
//    QBSPayConfig *config = [[self alloc] init];
//    config.mchId = @"5712000010";
//    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWft.json";
//    config.signKey = @"5afe11de0df374f5f78839db1904ff0d";
//    return config;
//}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.mchId forKey:@"mchId"];
    [dicRep safelySetObject:self.signKey forKey:@"signKey"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    QBSPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@implementation QBHTPayConfig

+ (instancetype)defaultConfig {
    QBHTPayConfig *config = [[self alloc] init];
    config.mchId = @"10605";
    config.key = @"e7c549c833cb9108e6524d075942119d";
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyHtPay.json";
    return config;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.mchId forKey:@"mchId"];
    [dicRep safelySetObject:self.key forKey:@"key"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    QBHTPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}

@end

@implementation QBMingPayConfig

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.mch forKey:@"mch"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    QBMingPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}

@end

@implementation QBWeiYingPayConfig

@end

@implementation QBDXTXPayConfig

@end