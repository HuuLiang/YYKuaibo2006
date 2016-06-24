//
//  YYKPaymentConfig.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKURLResponse.h"

typedef NS_ENUM(NSUInteger, YYKSubPayType) {
    YYKSubPayTypeUnknown = 0,
    YYKSubPayTypeWeChat = 1 << 0,
    YYKSubPayTypeAlipay = 1 << 1
};

@interface YYKWeChatPaymentConfig : NSObject
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

//+ (instancetype)defaultConfig;
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
@property (nonatomic) NSNumber *supportPayTypes;

//+ (instancetype)defaultConfig;
@end

@interface YYKVIAPayConfig : NSObject

//@property (nonatomic) NSString *packageId;
@property (nonatomic) NSNumber *supportPayTypes;

@end

@interface YYKSPayConfig : NSObject
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end

@interface YYKHTPayConfig : NSObject
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end

@interface YYKPaymentConfig : YYKURLResponse

@property (nonatomic,retain) YYKWeChatPaymentConfig *weixinInfo;
@property (nonatomic,retain) YYKAlipayConfig *alipayInfo;
@property (nonatomic,retain) YYKIAppPayConfig *iappPayInfo;
@property (nonatomic,retain) YYKVIAPayConfig *syskPayInfo;
@property (nonatomic,retain) YYKSPayConfig *wftPayInfo;
@property (nonatomic,retain) YYKHTPayConfig *haitunPayInfo;

+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;

@end
