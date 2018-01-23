//
//  MLYPayManager.m
//  Pods
//
//  Created by Sean Yue on 2017/1/13.
//
//

#import "MLYPayManager.h"
#import "QBPaymentInfo.h"
#import <TABTSDK/TABTSDK.h>
#import "Aspects.h"
#import "SPayClient.h"
#import "QBDefines.h"
#import "NSString+md5.h"
#import "RACEXTScope.h"
#import <objc/runtime.h>
#import "QBPaymentManager.h"
#import "MBProgressHUD.h"

void setSPayClientInfoWithApplication(id self, SEL _cmd, UIApplication *application, NSDictionary *launchOptions, NSString *appId) {
    SPayClientWechatConfigModel *wechatConfigModel = [[SPayClientWechatConfigModel alloc] init];
    
    wechatConfigModel.appScheme = appId;
    wechatConfigModel.wechatAppid = appId;
    
    //配置微信APP支付
    [[SPayClient sharedInstance] wechatpPayConfig:wechatConfigModel];
    
    [[SPayClient sharedInstance] application:application
               didFinishLaunchingWithOptions:launchOptions];
}

@interface MLYPayManager ()
@property (nonatomic) QBPaymentCompletionHandler completionHandler;
@property (nonatomic) QBPaymentInfo *paymentInfo;
@end

@implementation MLYPayManager

+ (instancetype)sharedManager {
    static MLYPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        
        id delegate = [UIApplication sharedApplication].delegate;
        class_addMethod([delegate class], @selector(setSPayClientInfoWithApplication:Options:appId:), (IMP)setSPayClientInfoWithApplication, "v@:@@@");
    });
    return _sharedManager;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (self.key.length == 0 || self.mchId.length == 0 || self.appid == 0 || self.channelId.length == 0 || paymentInfo.orderPrice == 0) {
        QBLog(@"萌乐游支付参数错误");
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *currency;
    if (paymentInfo.paymentSubType == QBPaySubTypeWeChat) {
        currency = @"1000200010000000";
    } else if (paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
        currency = @"1000200020000000";
    } else {
        QBLog(@"萌乐游支付参数错误");
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    ZWXPayModel *payModel = [[ZWXPayModel alloc] init];
    payModel.channelId = self.mchId;
    payModel.appId = self.appid;
    payModel.qd = self.channelId;
    payModel.appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    payModel.pricePointName = paymentInfo.orderDescription;
    payModel.pricePointDec = paymentInfo.orderDescription;
    payModel.appFeeName = [paymentInfo.orderDescription stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    payModel.money = @(paymentInfo.orderPrice).stringValue;
    payModel.cpParam = [NSString stringWithFormat:@"%@$%@", paymentInfo.orderId, paymentInfo.reservedData];
    payModel.appName = @"xxxx";
    payModel.packageName = @"com.xxxx.xxxx";
    payModel.sign = [NSString stringWithFormat:@"%@%@%@%@%@%@",payModel.channelId,payModel.qd,payModel.appId,@"0",currency,self.key].md5;
    
    @weakify(self);
    self.paymentInfo = paymentInfo;
    self.completionHandler = completionHandler;
    
    ZWXPaySDK_1 *paySDK = [[ZWXPaySDK_1 alloc] init];
    [paySDK tbatWithZWXPayModel:payModel ViewController:[UIApplication sharedApplication].keyWindow.rootViewController complete:^(ZWXPayRespObject *respObject) {
        @strongify(self);
        if (!respObject.status) {
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            self.paymentInfo = nil;
            self.completionHandler = nil;
        }
    }];
//    payModel.channelId = @"1000100020000054";
//    self.payModel.appId = @"2318";
//    self.payModel.qd = @"sdk_v6.0.00";
//    self.payModel.appVersion = @"1.0.00";
//    self.payModel.pricePointName = @"道具名称";
//    self.payModel.pricePointDec = @"商品描述";
//    self.payModel.appFeeName = @"计费点商品";
//    self.payModel.money = @"1";//以分为单位 不能出现小数
//    self.payModel.appFeeName = [self.payModel.appFeeName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    self.payModel.cpParam = @"261215095524963109";
//    self.payModel.cpParam = @"12";
//    self.payModel.appName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
//    self.payModel.packageName = @"com.tbat.sdk";
//    
//    
//    /**********客户端不需要传  测试需要*****************/
//    //默认 微信  1000200010000000
//    //    支付宝 1000200020000000
//    //
//    self.payModel.currency = @"1000200010000000";
//    self.payModel.appFeeId = @"0";//默认 是 0
//    self.payModel.key = @"0812CCB3434B40918EC0359E644AAE72";
//    /**********客户端不需要传  测试需要*****************/
//    
//    
//    /***********服务器加密********************/
//    self.payModel.sign = [NSString stringWithFormat:@"%@%@%@%@%@%@",self.payModel.channelId,self.payModel.qd,self.payModel.appId,self.payModel.appFeeId,self.payModel.currency,self.payModel.key];//md5加密 私钥
//    
//    self.payModel.sign = [self.payModel.sign stringToMD5: self.payModel.sign];
}

- (void)handleOpenURL:(NSURL *)url {
    [[SPayClient sharedInstance] application:[UIApplication sharedApplication] handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo == nil) {
        return ;
    }
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[QBPaymentManager sharedManager] activatePaymentInfos:@[self.paymentInfo] withRetryTimes:3 completionHandler:^(BOOL success, id obj) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
        
        self.paymentInfo = nil;
        self.completionHandler = nil;
    }];
}
@end
