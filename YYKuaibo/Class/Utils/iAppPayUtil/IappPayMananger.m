//
//  IappPayMananger.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "IappPayMananger.h"
#import <IapppayAlphaKit/IapppayAlphaKit.h>
#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
#import "YYKPaymentInfo.h"

@interface IappPayMananger () <IapppayAlphaKitPayRetDelegate>
@property (nonatomic,copy) YYKPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) YYKPaymentInfo *paymentInfo;
@end

@implementation IappPayMananger

+ (instancetype)sharedMananger {
    static IappPayMananger *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setAlipayURLScheme:(NSString *)alipayURLScheme {
    _alipayURLScheme = alipayURLScheme;
    [IapppayAlphaKit sharedInstance].appAlipayScheme = alipayURLScheme;
}

- (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo payType:(YYKSubPayType)payType completionHandler:(YYKPaymentCompletionHandler)completionHandler {
    NSDictionary *payTypeMapping = @{@(YYKSubPayTypeWeChat):@(IapppayAlphaKitWeChatPayType),
                                     @(YYKSubPayTypeAlipay):@(IapppayAlphaKitAlipayPayType)};
    if (!payTypeMapping[@(payType)]) {
        completionHandler(PAYRESULT_FAIL, paymentInfo);
        return ;
    }
    
    self.completionHandler = completionHandler;
    self.paymentInfo = paymentInfo;
    
    IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
    order.appId = self.appId;
    order.cpPrivateKey = self.privateKey;
    order.cpOrderId = paymentInfo.orderId;
    order.waresId = self.waresid;
    order.price = [NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice.unsignedIntegerValue/100.];
    order.appUserId = self.appUserId;
    order.cpPrivateInfo = self.privateInfo;
    order.notifyUrl = self.notifyUrl;

    NSString *trandData = [order getTrandData];
    [[IapppayAlphaKit sharedInstance] makePayForTrandInfo:trandData payMethodType:[payTypeMapping[@(payType)] integerValue] payDelegate:self];
}

- (void)handleOpenURL:(NSURL *)url {
    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
}

#pragma mark - IapppayAlphaKitPayRetDelegate

- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode resultInfo:(NSDictionary *)resultInfo {
    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(PAYRESULT_SUCCESS),
                                           @(IapppayAlphaKitPayRetFailedCode):@(PAYRESULT_FAIL),
                                           @(IapppayAlphaKitPayRetCancelCode):@(PAYRESULT_ABANDON)};
    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
    if (!paymentResult) {
        paymentResult = @(PAYRESULT_UNKNOWN);
    }

    NSString *signature = [resultInfo objectForKey:@"Signature"];
    if (paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
        if (![IapppayAlphaOrderUtils checkPayResult:signature withAppKey:self.publicKey]) {
            DLog(@"支付成功，但是延签失败！");
            paymentResult = @(PAYRESULT_FAIL);
        }
    }
    SafelyCallBlock(self.completionHandler, paymentResult.unsignedIntegerValue, self.paymentInfo);
    self.completionHandler = nil;
    self.paymentInfo = nil;
}
@end
