//
//  HTPayManager.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/9/1.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "HTPayManager.h"
#import "HaiTunPay.h"
#import "YYKWebViewController.h"
#import <AFNetworking.h>
#import "SPayClient.h"
#import "SPayClientWechatConfigModel.h"

static NSString *const kPayUrl = @"http://p.ylsdk.com/";
static NSString *const kQueryOrderUrl = @"http://c.ylsdk.com/";

@implementation HTPayManager

+ (instancetype)sharedManager {
    static HTPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [HaiTunPay shareInstance].haiTunPayBaseUrl = kPayUrl;
        [HaiTunPay shareInstance].haiTunSelectUrl = kQueryOrderUrl;
        [HaiTunPay shareInstance].Sjt_Paytype = @"b";
    }
    return self;
}

- (void)setup {
    SPayClientWechatConfigModel *wechatConfigModel = [[SPayClientWechatConfigModel alloc] init];
    wechatConfigModel.appScheme = @"wxd3c9c179bb827f2c";
    wechatConfigModel.wechatAppid = @"wxd3c9c179bb827f2c";
    [[SPayClient sharedInstance] wechatpPayConfig:wechatConfigModel];
    
    [[SPayClient sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
}

- (void)handleOpenURL:(NSURL *)url {
    [[SPayClient sharedInstance] application:[UIApplication sharedApplication] handleOpenURL:url];
}

- (void)setMchId:(NSString *)mchId {
    _mchId = mchId;
    [HaiTunPay shareInstance].merId = mchId;
}

- (void)setKey:(NSString *)key {
    _key = key;
    [HaiTunPay shareInstance].haiTunPaySignVal = key;
}

- (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo
         completionHandler:(YYKPaymentCompletionHandler)completionHandler
{
    NSDictionary *postInfo = @{@"p2_Order": paymentInfo.orderId,//商户订单号
                               @"p3_Amt": [NSString stringWithFormat:@"%.2f",paymentInfo.orderPrice.floatValue/100],//支付金额
                               @"p7_Pdesc": paymentInfo.orderDescription,//商品描述
                               @"p8_Url": self.notifyUrl ?: @"",//支付成功后会跳转此地址
                               @"Sjt_UserName": paymentInfo.reservedData ?: @""//支付用户
                               };
    
    @weakify(self);
    [[UIApplication sharedApplication].keyWindow beginLoading];
    [[HaiTunPay shareInstance] requestWithUrl:kPayUrl
                               viewcontroller:[YYKUtil currentVisibleViewController]
                                  requestType:RequestTypePOST
                                       parDic:postInfo
                                       finish:^(NSData *data)
    {
        [[UIApplication sharedApplication].keyWindow endLoading];
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        DLog(@"HaiTun Pay Response: %@", response);
        
        if ([response[@"error"] integerValue] != 9999) {
            SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
            return ;
        }
        
//        NSString *urlString = response[@"message"];
//        
//        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        YYKWebViewController *webVC = [[YYKWebViewController alloc] initWithURL:url standbyURL:nil];
//        webVC.title = @"微信支付";
//        [webVC.view setLoadingViewActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [webVC.view beginLoading];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
//        
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:^{
            [UIAlertView bk_showAlertViewWithTitle:@"完成支付后，按[确定]继续。"
                                           message:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 @strongify(self);
                 [[UIApplication sharedApplication].keyWindow beginLoading];
                 
                 [self checkPayment:paymentInfo withCompletionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
//                     [nav dismissViewControllerAnimated:YES completion:nil];
                     
                     [[UIApplication sharedApplication].keyWindow endLoading];
                     SafelyCallBlock(completionHandler, payResult, paymentInfo);
                 }];
                 
             }];
//        }];
    } error:^(NSError *error) {
        DLog(@"HaiTun Pay Error: %@", error.localizedDescription);
        SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
    } failure:^(NSString *failure) {
        DLog(@"HaiTun Pay Error: %@", failure);
 //       SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
    }];
}

- (void)checkPayment:(YYKPaymentInfo *)paymentInfo withCompletionHandler:(YYKPaymentCompletionHandler)completionHandler {
    NSDictionary *transDic = @{@"Sjt_TransID": paymentInfo.orderId};
    
//    paymentInfo.orderId = @"IOS_B_00000001_25ef3c0829913bb6";
    
//    [[HaiTunPay shareInstance] requestWithUrl:kQueryOrderUrl requestType:RequestTypePOST parDic:transDic finish:^(NSData *data) {
//        
//    } error:^(NSError *error) {
//        DLog(@"HaiTun Pay Error: %@", error.localizedDescription);
//        SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
//    } result:^(NSString *state) {
//        DLog(@"HaiTun Pay Order state: %@", state);
//        SafelyCallBlock(completionHandler, [state isEqualToString:@"1"] ? PAYRESULT_SUCCESS : PAYRESULT_FAIL, paymentInfo);
//    }];
//    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json",@"text/json", nil];
    
    [sessionManager POST:kQueryOrderUrl
              parameters:transDic
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
     {
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         DLog(@"海豚支付-查询订单： %@", response);
         
         BOOL success = [response[@"status"] isEqual:@"1"];
         SafelyCallBlock(completionHandler, success ? PAYRESULT_SUCCESS : PAYRESULT_FAIL, paymentInfo);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         DLog(@"海豚支付-查询订单错误：%@", error.localizedDescription);
         SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
     }];
}
@end
