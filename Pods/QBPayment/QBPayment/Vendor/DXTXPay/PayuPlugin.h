//
//  PayuPlugin.h
//  DXTXPaySDKDemo
//
//  Created by jmap on 16/9/7.
//  Copyright © 2016年 DXTXPaySDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  支付平台枚举
 */
typedef enum{
    PayTypeAliPay = 1,
    PayTypeWX
}PayType;

typedef void (^PayCompleteBlock)(NSDictionary *result);

@interface PayuPlugin : NSObject

/**
 *  SpaySDK 当前版本号
 *
 *  @return 版本号
 */
- (NSString*)spaySDKVersion;

/**
 *  创建支付单例服务
 *
 *  @return 返回单例对象
 */
+ (PayuPlugin *)defaultPlugin;

/**
 *  支付控件注册
 *
 *  @param appKey 支付品台获取的appKey
 */
- (void)registWithAppKey:(NSString *)appKey;



/**
 *  支付
 *
 *  @param pushFromCtrl  当前跳转的页面
 *  @param o_paymode_id  支付平台类型
 *  @param o_bizcode     商户订单号
 *  @param o_goods_id    商品id
 *  @param o_goods_name  商品名称（不传就已后台配置为准）
 *  @param o_price       商品价格
 *  @param o_privateinfo 商户私有信息,放置需要回传的信息(utf-8)
 *  @param appKey 支付品台获取的appKey
 */
- (void)payWithViewController:(UIViewController *)pushFromCtrl
                 o_paymode_id:(PayType)o_paymode_id
                    O_bizcode:(NSString *)o_bizcode
                   o_goods_id:(int)o_goods_id
                 o_goods_name:(NSString *)o_goods_name
                      o_price:(double)o_price
                o_privateinfo:(NSString *)o_privateinfo
                       Scheme:(NSString *)schemeStr
                       AppKey:(NSString *)appKey
                completeBlock:(PayCompleteBlock)completeBlock;


/**
 *  微信支付需要调用 iOS版微信Wap支付
 *
 *  @param application
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;


/**
 *  处理支付回调 
 *
 *  @param url           回调地址
 */
- (void)processOrderWithPaymentResult:(NSURL *)url;
@end
