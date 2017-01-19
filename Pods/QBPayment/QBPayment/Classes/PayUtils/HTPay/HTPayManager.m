//
//  HTPayManager.m
//  QBuaibo
//
//  Created by Sean Yue on 16/9/1.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "HTPayManager.h"
#import "HaiTunPay.h"
#import <AFNetworking.h>
#import "SPayClient.h"
#import "SPayClientWechatConfigModel.h"
#import "QBPaymentInfo.h"
#import "RACEXTScope.h"
#import "MBProgressHUD.h"

static NSString *const kPayUrl = @"http://p.ylsdk.com/";
static NSString *const kQueryOrderUrl = @"http://c.ylsdk.com/";

@interface HTPayManager ()
@property (nonatomic,copy) QBCompletionHandler completionHandler;
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@end

@implementation HTPayManager

+ (instancetype)sharedManager {
    static HTPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
    
    [HaiTunPay shareInstance].haiTunPayBaseUrl = kPayUrl;
    [HaiTunPay shareInstance].haiTunSelectUrl = kQueryOrderUrl;
    [HaiTunPay shareInstance].Sjt_Paytype = self.payType;
    
//    [[HaiTunPay shareInstance] registAppid:[UIApplication sharedApplication] launchOptions:nil];
}

- (void)handleOpenURL:(NSURL *)url {
    [[SPayClient sharedInstance] application:[UIApplication sharedApplication] handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //[[SPayClient sharedInstance] applicationWillEnterForeground:application];
    QBSafelyCallBlock(self.completionHandler, YES, self.paymentInfo);
}

- (void)setMchId:(NSString *)mchId {
    _mchId = mchId;
    [HaiTunPay shareInstance].merId = mchId;
}

- (void)setKey:(NSString *)key {
    _key = key;
    [HaiTunPay shareInstance].haiTunPaySignVal = key;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBCompletionHandler)completionHandler
{
    NSDictionary *postInfo = @{@"p2_Order": paymentInfo.orderId,//商户订单号
                               @"p3_Amt": [NSString stringWithFormat:@"%.2f",paymentInfo.orderPrice/100.],//支付金额
                               @"p7_Pdesc": paymentInfo.orderDescription,//商品描述
                               @"p8_Url": self.notifyUrl ?: @"",//支付成功后会跳转此地址
                               @"Sjt_UserName": paymentInfo.reservedData ?: @""//支付用户
                               };
    
    @weakify(self);
    [[HaiTunPay shareInstance] requestWithUrl:kPayUrl
                               viewcontroller:[UIApplication sharedApplication].keyWindow.rootViewController
                                  requestType:RequestTypePOST
                                       parDic:postInfo
                                  application:[UIApplication sharedApplication]
                                launchOptions:nil
                                       finish:^(NSData *data)
    {
        @strongify(self);
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        QBLog(@"HaiTun Pay Response: %@", response);
        
        if ([response[@"error"] integerValue] != 9999) {
            QBSafelyCallBlock(completionHandler, NO, paymentInfo);
            return ;
        }
        
        self.completionHandler = ^(BOOL success, id obj) {
            @strongify(self);
            QBSafelyCallBlock(completionHandler, success, paymentInfo);
            self.completionHandler = nil;
            self.paymentInfo = nil;
        };
        
        self.paymentInfo = paymentInfo;
    } error:^(NSError *error) {
        QBLog(@"HaiTun Pay Error: %@", error.localizedDescription);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
    } failure:^(NSString *failure) {
        QBLog(@"HaiTun Pay Error: %@", failure);
    }];
//    [[HaiTunPay shareInstance] requestWithUrl:kPayUrl
//                               viewcontroller:[UIApplication sharedApplication].keyWindow.rootViewController
//                                  requestType:RequestTypePOST
//                                       parDic:postInfo
//                                       finish:^(NSData *data)
//    {
//        
//        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        
//        QBLog(@"HaiTun Pay Response: %@", response);
//        
//        if ([response[@"error"] integerValue] != 9999) {
//            QBSafelyCallBlock(completionHandler, NO, paymentInfo);
//            return ;
//        }
//        
//        self.completionHandler = ^(BOOL success, id obj) {
//            @strongify(self);
//            QBSafelyCallBlock(completionHandler, success, paymentInfo);
//            self.completionHandler = nil;
//            self.paymentInfo = nil;
//        };
//        
//        self.paymentInfo = paymentInfo;
//    } error:^(NSError *error) {
//        QBLog(@"HaiTun Pay Error: %@", error.localizedDescription);
//        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
//    } failure:^(NSString *failure) {
//        QBLog(@"HaiTun Pay Error: %@", failure);
// //       SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
//    }];
}

//- (void)checkPayment:(QBPaymentInfo *)paymentInfo retryTimes:(NSUInteger)retryTimes withCompletionHandler:(QBPaymentCompletionHandler)completionHandler
//{
//    @weakify(self);
//    [self checkPayment:paymentInfo withCompletionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
//        @strongify(self);
//        if (retryTimes == 0 || payResult == QBPayResultSuccess) {
//            QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
//        } else {
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [NSThread sleepForTimeInterval:2];
//                [self checkPayment:paymentInfo retryTimes:retryTimes-1 withCompletionHandler:completionHandler];
//            });
//        }
//    }];
//}

//- (void)checkPayment:(QBPaymentInfo *)paymentInfo withCompletionHandler:(QBPaymentCompletionHandler)completionHandler {
//    NSDictionary *transDic = @{@"Sjt_TransID": paymentInfo.orderId};
//    
////    paymentInfo.orderId = @"IOS_B_00000001_25ef3c0829913bb6";
//    
////    [[HaiTunPay shareInstance] requestWithUrl:kQueryOrderUrl requestType:RequestTypePOST parDic:transDic finish:^(NSData *data) {
////        
////    } error:^(NSError *error) {
////        DLog(@"HaiTun Pay Error: %@", error.localizedDescription);
////        SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
////    } result:^(NSString *state) {
////        DLog(@"HaiTun Pay Order state: %@", state);
////        SafelyCallBlock(completionHandler, [state isEqualToString:@"1"] ? PAYRESULT_SUCCESS : PAYRESULT_FAIL, paymentInfo);
////    }];
////
//    
//    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
//    sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
//    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json",@"text/json", nil];
//    
//    [sessionManager POST:kQueryOrderUrl
//              parameters:transDic
//                progress:nil
//                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
//     {
//         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//         QBLog(@"海豚支付-查询订单： %@", response);
//         
//         BOOL success = [response[@"status"] isEqual:@"1"];
//         QBSafelyCallBlock(completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, paymentInfo);
//     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//         QBLog(@"海豚支付-查询订单错误：%@", error.localizedDescription);
//         QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
//     }];
//}
@end
