//
//  QBPaymentManager.h
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"
#import "QBDefines.h"

FOUNDATION_EXTERN NSString *const kQBPaymentFetchConfigNotification;

@interface QBPaymentManager : NSObject

+ (instancetype)sharedManager;

/**
 *  注册支付所用的appId, 支付的版本号，渠道号，以及
 *
 *  @param appId     appId
 *  @param pv        支付版本号(用于获取支付配置)
 *  @param channelNo 渠道号
 *  @param urlScheme 支付宝回调所用的url scheme；在某些第三方支付中，如果不注册该url scheme，可能会在调起时崩溃
 */
- (void)registerPaymentWithAppId:(NSString *)appId paymentPv:(NSNumber *)pv channelNo:(NSString *)channelNo urlScheme:(NSString *)urlScheme;

/**
 *  开启支付
 *
 *  @param paymentInfo       支付信息
 *  @param completionHandler 回调block
 *
 *  @return 是否成功开启
 */
- (BOOL)startPaymentWithPaymentInfo:(QBPaymentInfo *)paymentInfo
                  completionHandler:(QBPaymentCompletionHandler)completionHandler;

- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)handleOpenUrl:(NSURL *)url;

- (QBPayType)wechatPaymentType;
- (QBPayType)alipayPaymentType;
- (QBPayType)cardPayPaymentType;
- (QBPayType)qqPaymentType;

- (BOOL)IsSDKIntegratedForPayType:(QBPayType)payType;

- (void)refreshAvailablePaymentTypesWithCompletionHandler:(void (^)(void))completionHandler;

- (void)usePaymentConfigInTestServer:(BOOL)useTestConfig;

- (void)activatePaymentInfos:(NSArray<QBPaymentInfo *> *)paymentInfos withCompletionHandler:(QBCompletionHandler)completionHandler;

@end
