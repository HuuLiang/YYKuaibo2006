//
//  YYKPaymentConfig.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKURLResponse.h"

@interface YYKWeChatPaymentConfig : NSObject
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)defaultConfig;
@end

@interface YYKAlipayConfig : NSObject
@property (nonatomic) NSString *partner;
@property (nonatomic) NSString *seller;
@property (nonatomic) NSString *productInfo;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *notifyUrl;
@end

@interface YYKIAppPayConfig : NSObject
@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;

+ (instancetype)defaultConfig;
@end

@interface YYKPaymentConfig : YYKURLResponse

@property (nonatomic,retain) YYKWeChatPaymentConfig *weixinInfo;
@property (nonatomic,retain) YYKAlipayConfig *alipayInfo;
@property (nonatomic,retain) YYKIAppPayConfig *iappPayInfo;

+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;

@end