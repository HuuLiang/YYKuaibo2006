//
//  QBPaymentConfigDetail.h
//  QBuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBURLResponse.h"

@class QBIAppPayConfig;
@class QBVIAPayConfig;
@class QBMingPayConfig;
@class QBSPayConfig;
@class QBHTPayConfig;
@class QBWeiYingPayConfig;
@class QBDXTXPayConfig;
@class QBMTDLPayConfig;

extern NSString *const kQBIAppPayConfigName;
extern NSString *const kQBVIAPayConfigName;
extern NSString *const kQBMingPayConfigName;
extern NSString *const kQBSPayConfigName;
extern NSString *const kQBHTPayConfigName;
extern NSString *const kQBMTDLPayConfigName;
extern NSString *const kQBWeiYingConfigName;
extern NSString *const kQBDXTXPayConfigName;

@interface QBPaymentConfigDetail : NSObject <QBResponseParsable>

@property (nonatomic,retain) QBIAppPayConfig *iAppPayConfig; //爱贝支付
@property (nonatomic,retain) QBVIAPayConfig *viaPayConfig; //首游时空
@property (nonatomic,retain) QBMingPayConfig *mingPayConfig; //明鹏支付
@property (nonatomic,retain) QBSPayConfig *spayConfig; //威富通
@property (nonatomic,retain) QBHTPayConfig *htpayConfig; //海豚支付
@property (nonatomic,retain) QBDXTXPayConfig *dxtxPayConfig; //盾行天下
@property (nonatomic,retain) QBWeiYingPayConfig *weiYingPayConfig; //微赢支付
@property (nonatomic,retain) QBMTDLPayConfig *mtdlPayConfig; //明天动力

@end

@interface QBIAppPayConfig : NSObject

@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;
@property (nonatomic) NSNumber *supportPayTypes;

+ (instancetype)defaultConfig;
@end

@interface QBVIAPayConfig : NSObject

//@property (nonatomic) NSString *packageId;
@property (nonatomic) NSNumber *supportPayTypes;

+ (instancetype)defaultConfig;

@end

@interface QBMingPayConfig : NSObject

@property (nonatomic) NSString *payUrl;
@property (nonatomic) NSString *queryOrderUrl;
@property (nonatomic) NSString *mch;

@end

@interface QBSPayConfig : NSObject
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end

@interface QBHTPayConfig : NSObject
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end

@interface QBWeiYingPayConfig : NSObject
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end

@interface QBDXTXPayConfig : NSObject

@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;

@end

@interface QBMTDLPayConfig : NSObject

@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *notifyUrl;

@end
