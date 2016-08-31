//
//  YYKPaymentConfigDetail.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYKIAppPayConfig;
@class YYKVIAPayConfig;
@class YYKMingPayConfig;
@class YYKSPayConfig;

extern NSString *const kYYKIAppPayConfigName;
extern NSString *const kYYKVIAPayConfigName;
extern NSString *const kYYKMingPayConfigName;
extern NSString *const kYYKSPayConfigName;

@interface YYKPaymentConfigDetail : NSObject <YYKResponseParsable>

@property (nonatomic,retain) YYKIAppPayConfig *iAppPayConfig; //爱贝支付
@property (nonatomic,retain) YYKVIAPayConfig *viaPayConfig; //首游时空
@property (nonatomic,retain) YYKMingPayConfig *mingPayConfig; //明鹏支付
@property (nonatomic,retain) YYKSPayConfig *spayConfig; //威富通

@end

@interface YYKIAppPayConfig : NSObject
@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;
@property (nonatomic) NSNumber *supportPayTypes;

+ (instancetype)defaultConfig;
@end

@interface YYKVIAPayConfig : NSObject

//@property (nonatomic) NSString *packageId;
@property (nonatomic) NSNumber *supportPayTypes;

+ (instancetype)defaultConfig;

@end

@interface YYKMingPayConfig : NSObject

@property (nonatomic) NSString *mch;

@end

@interface YYKSPayConfig : NSObject
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end
//
//@interface YYKHTPayConfig : NSObject
//@property (nonatomic) NSString *key;
//@property (nonatomic) NSString *mchId;
//@property (nonatomic) NSString *notifyUrl;
//@end
