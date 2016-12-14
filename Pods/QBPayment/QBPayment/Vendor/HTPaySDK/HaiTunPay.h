//
//  HaiTunPay.h
//  HaiTunPay
//
//  Created by TKJF on 16/7/5.
//  Copyright © 2016年 TKJF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SPayClientHeaders.h"

typedef void(^Finish)(NSData *data);//请求成功
typedef void(^Error)(NSError *error);//请求失败
typedef void(^Failure)(NSString *failure);//条件不符合错误
typedef void(^Result)(NSString *state);//订单状态

typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypePOST,
    RequestTypeGET
};

@interface HaiTunPay : NSObject

//属性保存外界传过来的Block
@property (nonatomic, copy)Finish finish;
@property (nonatomic, copy)Error error;
@property (nonatomic, copy)Failure failure;
@property (nonatomic, copy)Result result;

//商户密钥值
@property (nonatomic, copy)NSString *haiTunPaySignVal;
//请求地址
@property (nonatomic, copy)NSString *haiTunPayBaseUrl;
//商户编号
@property (nonatomic, copy)NSString *merId;
//查询订单请求地址
@property (nonatomic, copy)NSString *haiTunSelectUrl;
//支付类型
@property (nonatomic, copy)NSString *Sjt_Paytype;

//给这个类一个网址、参数、请求方式 让这个类返回数据（NSData）
//1、属性  2、方法(给这个类东西)
//1、Block  2、代理
//支付方法
- (void)requestWithUrl:(NSString *)urlSting viewcontroller:(UIViewController *)viewcontroller  requestType:(RequestType)requestType parDic:(NSDictionary *)parDic finish:(Finish)finish error:(Error)error failure:(Failure)failuer;


//单例
+ (HaiTunPay *)shareInstance;
//微信注册appid
- (void)registAppid:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions;
 
//设置参数值
+(instancetype)RequestManagerWithHaiTunPaySignVal:(NSString *)haiTunPaySignVal
                                 haiTunPayBaseUrl:(NSString *)haiTunPayBaseUrl
                                            merId:(NSString *)merId
                                Sjt_Paytype:(NSString *)Sjt_Paytype;
@end
