//
//  WJPayManager.m
//  Pods
//
//  Created by Sean Yue on 2016/11/28.
//
//

#import "WJPayManager.h"
#import "FFLPaySDK/FFLPaySDK.h"
#import "QBPaymentInfo.h"
#import "QBNetworkInfo.h"
#import "QBDefines.h"
#import "MBProgressHUD.h"

@implementation WJPayManager

+ (instancetype)sharedManager {
    static WJPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
    [[FFLPayClient sharedInstance] setupMchID:self.mchId MchKey:self.signKey];
    [[FFLPayClient sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (self.mchId.length == 0 || paymentInfo.orderId.length == 0) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSDictionary *postInfo = [[FFLPayClient sharedInstance] makePayForm:self.mchId
                                                              PayTypeId:@"wechat_sdk"
                                                             MchTradeNo:paymentInfo.orderId
                                                           TradeContent:paymentInfo.orderDescription//[paymentInfo.orderDescription stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
                                                            TradeAttach:paymentInfo.reservedData//[paymentInfo.reservedData stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
                                                             TradeMoney:@(paymentInfo.orderPrice).stringValue
                                                                     Ip:[QBNetworkInfo sharedInfo].ipAddress
                                                              NotifyUrl:self.notifyUrl
                                                            RedirectUrl:@""];
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[FFLPayClient sharedInstance] fflpay_prepay:postInfo success:^(id operation, id responseObject) {
        NSDictionary *payInfo = responseObject;
        
        QBLog(@"WJ prepay message: %@", payInfo[@"Message"]);
        
        if (((NSString *)payInfo[@"PayWay"]).length == 0) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        [[FFLPayClient sharedInstance] fflpay_wechatAppPay:[UIApplication sharedApplication].keyWindow.rootViewController
                                                   payinfo:payInfo
                                                   finish:^(NSDictionary *payInfo)
        {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            
            NSInteger code = [payInfo[@"code"] integerValue];
            QBSafelyCallBlock(completionHandler, code == FFLPayEnum_PaySuccess ? QBPayResultSuccess : QBPayResultFailure, paymentInfo);
        }];
    } failure:^(id operation, NSError *error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        
        QBLog(@"WJ prepay error: %@", error.localizedDescription);
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[FFLPayClient sharedInstance] applicationWillEnterForeground:application];
}
@end
