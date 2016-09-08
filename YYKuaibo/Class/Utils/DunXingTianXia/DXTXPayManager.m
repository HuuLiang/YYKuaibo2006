//
//  DXTXPayManager.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/9/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "DXTXPayManager.h"
#import <AFNetworking.h>
#import "YYKWebViewController.h"
#import "YYKOrderQueryModel.h"

static NSString *const kPayUrl = @"http://payment.payjumi.com/Pay.ashx";

@implementation DXTXPayManager

+ (instancetype)sharedManager {
    static DXTXPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo
         completionHandler:(YYKPaymentCompletionHandler)completionHandler
{
    if (self.appKey.length == 0 || self.waresid == nil || paymentInfo.orderId.length == 0 || paymentInfo.orderDescription.length == 0) {
        SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
        return ;
    }
    
    NSUInteger payMode = 0;
    if (paymentInfo.paymentSubType.unsignedIntegerValue == YYKSubPayTypeAlipay) {
        payMode = 1;
    } else if (paymentInfo.paymentSubType.unsignedIntegerValue == YYKSubPayTypeWeChat) {
        payMode = 2;
    } else {
        SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
        return ;
    }
    
    NSMutableDictionary *params = @{@"o_bizcode":paymentInfo.orderId,
                                    @"o_appkey":self.appKey,
                                    @"o_paymode_id":@(payMode),
                                    @"o_showaddress":@"http://www.baidu.com",
                                    @"o_goods_id":self.waresid,
                                    @"o_goods_name":paymentInfo.orderDescription,
                                    @"o_price":@(paymentInfo.orderPrice.floatValue/100)}.mutableCopy;
    
    NSString *termKey = [YYKUtil userId].length > 0 ? [YYKUtil userId] : [YYKUtil accessId].length > 0 ? [YYKUtil accessId] : [NSUUID UUID].UUIDString;
    termKey = [termKey stringByAppendingString:self.appKey].md5;
    [params setObject:termKey forKey:@"o_term_key"];
    [params safelySetObject:self.notifyUrl forKey:@"o_address"];
    [params safelySetObject:paymentInfo.reservedData forKey:@"o_privateinfo"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonString) {
        SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
        return ;
    }
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
    
    [[UIApplication sharedApplication].keyWindow beginLoading];
    [sessionManager POST:kPayUrl
              parameters:@{@"Pay":jsonString}
                 success:^(NSURLSessionDataTask * _Nonnull task,
                           id  _Nonnull responseObject)
    {
        [[UIApplication sharedApplication].keyWindow endLoading];
        DLog(@"DXTX payment response: %@", responseObject);
        
        NSInteger result = [responseObject[@"result"] integerValue];
        id payInfo = responseObject[@"data"];
        if (result != 100 || !payInfo) {
            SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
            return ;
        }
        
        YYKWebViewController *webVC;
        if (paymentInfo.paymentSubType.unsignedIntegerValue == YYKSubPayTypeWeChat && [payInfo isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:[payInfo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            webVC = [[YYKWebViewController alloc] initWithURL:url standbyURL:nil];
            webVC.title = @"微信支付";
            [webVC.view setLoadingViewActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [webVC.view beginLoading];
        } else if (paymentInfo.paymentSubType.unsignedIntegerValue == YYKSubPayTypeAlipay && [payInfo isKindOfClass:[NSDictionary class]]) {
            NSString *htmlString = payInfo[@"pay"];
            webVC = [[YYKWebViewController alloc] initWithHTML:htmlString];
            webVC.title = @"支付宝支付";
            
            @weakify(webVC);
            webVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"关闭" style:UIBarButtonItemStylePlain handler:^(id sender) {
                [UIAlertView bk_showAlertViewWithTitle:@"您是否确认已经完成支付？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
                        @strongify(webVC);
                        [webVC.navigationController dismissViewControllerAnimated:YES completion:nil];
                        
                        [[UIApplication sharedApplication].keyWindow beginLoading];
                        
                        [[[YYKOrderQueryModel alloc] init] queryOrder:paymentInfo.orderId withCompletionHandler:^(BOOL success, id obj) {
                            [[UIApplication sharedApplication].keyWindow endLoading];
                            SafelyCallBlock(completionHandler, success ? PAYRESULT_SUCCESS : PAYRESULT_FAIL, paymentInfo);
                        }];
                    }
                }];
            }];
        } else {
            SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
            return ;
        }
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:^{
            if (paymentInfo.paymentSubType.unsignedIntegerValue == YYKSubPayTypeWeChat) {
                [UIAlertView bk_showAlertViewWithTitle:@"完成支付后，按[确定]继续。"
                                               message:nil
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil
                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     [[UIApplication sharedApplication].keyWindow beginLoading];
                     
                     [[[YYKOrderQueryModel alloc] init] queryOrder:paymentInfo.orderId withCompletionHandler:^(BOOL success, id obj) {
                         [[UIApplication sharedApplication].keyWindow endLoading];
                         [nav dismissViewControllerAnimated:YES completion:nil];
                         
                         SafelyCallBlock(completionHandler, success ? PAYRESULT_SUCCESS : PAYRESULT_FAIL, paymentInfo);
                     }];
                 }];
            }
            
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow endLoading];
        DLog(@"DXTX payment error: %@", error.localizedDescription);
        SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
    }];
}
@end
