//
//  SPayUtil.m
//  QBPayment
//
//  Created by Sean Yue on 16/5/12.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "SPayUtil.h"
#import "QBPaymentInfo.h"
#import "SPRequestForm.h"
#import "SPHTTPManager.h"
#import "SPayClient.h"
#import "SPayClientWechatConfigModel.h"
#import "SPConst.h"
#import "QBDefines.h"
#import <XMLReader.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface SPayUtil ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;
@end

@implementation SPayUtil

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SPayUtil *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        SPayClientWechatConfigModel *configModel = [[SPayClientWechatConfigModel alloc] init];
        configModel.appScheme = @"wxd3a1cdf74d0c41b3";
        configModel.wechatAppid = @"wxd3a1cdf74d0c41b3";
        [[SPayClient sharedInstance] wechatpPayConfig:configModel];
    }
    return self;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler {
    NSString *service = @"unified.trade.pay";
    NSString *mch_id = self.mchId;
    NSString *out_trade_no = paymentInfo.orderId;
    NSString *body = paymentInfo.orderDescription;
    NSInteger total_fee = paymentInfo.orderPrice;
    NSString *mch_create_ip = [self getIPAddress];
    NSString *notify_url = self.notifyUrl;
    
    srand( (unsigned)time(0) );
    NSString *nonce_str  = [NSString stringWithFormat:@"%d", rand()];
    
    NSNumber *amount = [NSNumber numberWithInteger:total_fee];
    //生成提交表单
    NSDictionary *postInfo = [[SPRequestForm sharedInstance]
                              spay_pay_gateway:service
                              version:nil
                              charset:nil
                              sign_type:nil
                              sign_key:self.signKey
                              mch_id:mch_id
                              out_trade_no:out_trade_no
                              device_info:nil
                              body:body
                              total_fee:total_fee
                              mch_create_ip:mch_create_ip
                              notify_url:notify_url
                              time_start:nil
                              time_expire:nil
                              nonce_str:nonce_str
                              attach:paymentInfo.reservedData];
    
    //调用支付预下单接口
    [[SPHTTPManager sharedInstance] post:@"pay/gateway"
                                paramter:postInfo
                                 success:^(id operation, id responseObject)
     {
         //返回的XML字符串,如果解析有问题可以打印该字符串
         //        NSString *response = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
         
         NSError *erro;
         //XML字符串 to 字典
         //!!!! XMLReader最后节点都会设置一个kXMLReaderTextNodeKey属性
         //如果要修改XMLReader的解析，请继承该类然后再去重写，因为SPaySDK也是调用该方法解析数据，如果修改了会导致解析失败
         NSDictionary *info = [XMLReader dictionaryForXMLData:(NSData *)responseObject error:&erro];
         
         QBLog(@"预下单接口返回数据-->>\n%@",info);
         
         if (!info || ![info isKindOfClass:[NSDictionary class]]) {
             QBLog(@"预下单接口，解析数据失败");
             if (completionHandler) {
                 completionHandler(QBPayResultFailure, paymentInfo);
             }
             return ;
         }
         
         NSDictionary *xmlInfo = info[@"xml"];
         NSInteger status = [xmlInfo[@"status"][@"text"] integerValue];
         //判断SPay服务器返回的状态值是否是成功,如果成功则调起SPaySDK
         if (status != 0) {
             QBLog(@"预下单失败：%@", xmlInfo[@"message"][@"text"]);
             if (completionHandler) {
                 completionHandler(QBPayResultFailure, paymentInfo);
             }
             return ;
         }
         
         //获取SPaySDK需要的token_id
         NSString *token_id = xmlInfo[@"token_id"][@"text"];
         
         //获取SPaySDK需要的services
         //NSString *services = xmlInfo[@"services"][@"text"];
         
         //调起SPaySDK支付
         UIViewController *viewController = [[UIViewController alloc] init];
         viewController.view.backgroundColor = [UIColor whiteColor];
     
         UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
         [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
     
         [[SPayClient sharedInstance] pay:viewController
                                   amount:amount
                        spayTokenIDString:token_id
                        payServicesString:kSPconstSPayWeChatService
                                   finish:^(SPayClientPayStateModel *payStateModel,
                                            SPayClientPaySuccessDetailModel *paySuccessDetailModel)
         {
               [nav dismissViewControllerAnimated:YES completion:nil];
         
               if (payStateModel.payState == SPayClientConstEnumPaySuccess) {
                   QBLog(@"支付成功");
                   QBLog(@"支付订单详情-->>\n%@",[paySuccessDetailModel description]);
               }else{
                   QBLog(@"支付失败，错误号:%d",payStateModel.payState);
               }
               
               if (completionHandler) {
                   completionHandler([self payResultWithPayState:payStateModel.payState], paymentInfo);
               }
             
        }];
     } failure:^(id operation, NSError *error) {
         if (completionHandler) {
             completionHandler(QBPayResultFailure, paymentInfo);
         }
         QBLog(@"调用预下单接口失败-->>\n%@",error);
     }];
}

- (QBPayResult)payResultWithPayState:(SPayClientConstEnumPayState)payState {
    QBPayResult payResult = QBPayResultFailure;
    if (payState == SPayClientConstEnumPaySuccess) {
        payResult = QBPayResultSuccess;
    } else if (payState == SPayClientConstEnumWapPayOut) {
        payResult = QBPayResultCancelled;
    }
    return payResult;
}

- (void)applicationWillEnterForeground {
    [[SPayClient sharedInstance] applicationWillEnterForeground:[UIApplication sharedApplication]];
}

- (void)registerMchId:(NSString *)mchId signKey:(NSString *)signKey notifyUrl:(NSString *)notifyUrl {
    self.mchId = mchId;
    self.signKey = signKey;
    self.notifyUrl = notifyUrl;
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}
//+ (BOOL)application:(UIApplication *)application
//didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    SPayClientWechatConfigModel *configModel = [[SPayClientWechatConfigModel alloc] init];
//    configModel.appScheme = @"wxd3a1cdf74d0c41b3";
//    configModel.wechatAppid = @"wxd3a1cdf74d0c41b3";
//    [[SPayClient sharedInstance] wechatpPayConfig:configModel];
//    return [[SPayClient sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
//}
//
//+ (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    return [[SPayClient sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
//}
//
//+ (BOOL)application:(UIApplication *)application
//      handleOpenURL:(NSURL *)url {
//    return [[SPayClient sharedInstance] application:application handleOpenURL:url];
//}
//
//+ (BOOL)application:(UIApplication *)app
//            openURL:(NSURL *)url
//            options:(NSDictionary<NSString*, id> *)options {
//    return [[SPayClient sharedInstance] application:app openURL:url options:options];
//}
@end
