//
//  FFLPaySDK.h
//  FFLPaySDK-iOS
//
//  Created by YIF on 16/11/22.
//  Copyright © 2016年 88.la. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "FFLPaySDK.h"
#include "FFLPayHeader.h"

@interface FFLPayClient : NSObject


+ (FFLPayClient*)sharedInstance;


/**
 *  FFLPaySDK 设置商户ID、密钥Key
 */

- (void)setupMchID:(NSString*)mchid MchKey:(NSString*)mchkey;


/**
 *  FFLPaySDK 当前版本号
 */
- (NSString*)SDKVersion;




/**
 *  FFLPaySDK 版本类型
 *
 */
- (NSString*)SDKTypeName;



/**
 *  是否输出debug日志信息
 *
 *  @param output    YES 输出  NO不输出
 */
- (void)SDKLogOuput:(BOOL)output;

/**
 *  是否使用HTTPS请求接口
 *
 *  @param enabled    YES 使用  NO不使用
 */
- (void)SDKHttpsEnabled:(BOOL)enabled;



/**
 *  生成支付表单
 *
 *  @param MchId            商户号（必填）
 *  @param PayTypeId        接口类型（必填）
 *  @param MchTradeNo       商户订单号（必填）
 *  @param TradeContent     商品描述（必填）
 *  @param TradeAttach      设备号（非必填）
 *  @param TradeMoney       总金额 (必填)
 *  @param Ip               终端IP (必填)
 *  @param NotifyUrl        通知地址 (必填)
 *  @param RedirectUrl      支付成功的跳转地址 (必填)
 *
 *  @return "签名的订单"
 */
- (NSDictionary*)makePayForm:(NSString*)MchId
                   PayTypeId:(NSString*)PayTypeId
                  MchTradeNo:(NSString*)MchTradeNo
                TradeContent:(NSString*)TradeContent
                 TradeAttach:(NSString*)TradeAttach
                  TradeMoney:(NSString*)TradeMoney
                          Ip:(NSString*)Ip
                   NotifyUrl:(NSString*)NotifyUrl
                 RedirectUrl:(NSString*)RedirectUrl;



/**
 *  FFL支付预下单接口 1.0.1
 *
 *  @param parameter 请求参数
 *  @param success   成功回调
 *  @param failure   失败回调
 */
- (void)fflpay_prepay:(NSDictionary *)parameter
     success:(void (^)(id operation, id responseObject))success
     failure:(void (^)(id operation, NSError *error))failure;



/**
 *  FafaLaPay 微信支付
 *
 *  @param vc        当前支付所在的页面
 *  @param payinfo   请求参数
 *  @param finish    结果回调
 */
- (void)fflpay_wechatAppPay:(UIViewController*)vc
                    payinfo:(NSDictionary *)payinfo
                     finish:(FFLPayFinishBlock)finish;



/**
 *  FafaLaPay 支付订单支付状态
 *
 *  @param tradeNo   商户订单号（必填）
 *  @param PayTypeId 接口类型（必填）
 *  @param finish    结果回调 （必填）
 */

-(void)checkOrderStatus:(NSString*)tradeNo
              PayTypeId:(NSString*)PayTypeId
                 finish:(FFLPayFinishBlock)finish;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

// 使用微信APP支付和支付宝APP支付，必须实现以下三个UIApplicationDelegate代理方法
// 实现应用之间接收同步通知结果
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url;

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0);

//需要在AppDelegate 的applicationWillEnterForeground:方法中调用.
- (void)applicationWillEnterForeground:(UIApplication *)application;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url;

@end
