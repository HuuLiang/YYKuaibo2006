//
//  WYPayManager.h
//  WYPaySDKDemo
//
//  Created by 微赢互动 on 16/9/6.
//  Copyright © 2016年 微赢互动. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <HeePay/HYSDKManager.h>

//支付结果回调消息名称
#define WY_NOTIFICATION_SUCCESS  @"WY_NOTIFICATION_SUCCESS" //成功
#define WY_NOTIFICATION_FAIL  @"WY_NOTIFICATION_FAIL"       //失败
#define WY_NOTIFICATION_CANCEL  @"WY_NOTIFICATION_CANCEL"   //取消
#define WY_NOTIFICATION_LOADING  @"WY_NOTIFICATION_LOADING" //进行中
#define WY_NOTIFICATION_ERROR  @"WY_NOTIFICATION_ERROR"     //支付有问题（一般是数据问题）

@interface WYPayManager : NSObject<NSXMLParserDelegate>

+(BOOL)application:(UIApplication *)application openURL:(NSURL *)url;

+(void)heepaySDKWillEnterForeground;

/**
 *  viewController ---------------------    调用的视图一般为self
 *  agent_bill_id	---------------------   订单号 格式：商户号_自定义订单号
 *  pay_amt  		--------------------------  支付金额 支付金额最低2.00元  金额必须精确到分 例：2.00
 *  goods_name     ----------------------   商品名称  当有中文时必须使用utf8编码
 *  notify_url	    --------------------    异步通知地址
 *  custom      ------------------------    支付成功后该字段原样返回
 */

-(void)sendPayRequestWithViewController:(UIViewController *)viewController Agent_bill_id:(NSString *)agent_bill_id pay_amt:(NSString *)pay_amt goods_name:(NSString *)goods_name notify_url:(NSString *)notify_url custom:(NSString *)custom;

@end
