//
//  IappPayMananger.m
//  QBuaibo
//
//  Created by Sean Yue on 16/6/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "IappPayMananger.h"
#import <IapppayAlphaKit/IapppayAlphaKit.h>
#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
#import "QBDefines.h"
#import <QBPaymentDefines.h>
#import "QBPaymentInfo.h"

@interface IappPayMananger () <IapppayAlphaKitPayRetDelegate>
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
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

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
                   payType:(QBPaySubType)payType
         completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    NSDictionary *payTypeMapping = @{@(QBPaySubTypeWeChat):@(IapppayAlphaKitWeChatPayType),
                                     @(QBPaySubTypeAlipay):@(IapppayAlphaKitAlipayPayType)};
    if (!payTypeMapping[@(payType)]) {
        completionHandler(QBPayResultFailure, paymentInfo);
        return ;
    }
    
    self.completionHandler = completionHandler;
    self.paymentInfo = paymentInfo;
    
    IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
    order.appId = self.appId;
    order.cpPrivateKey = self.privateKey;
    order.cpOrderId = paymentInfo.orderId;
    order.waresId = self.waresid;
    order.price = [NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice/100.];
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
    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(QBPayResultSuccess),
                                           @(IapppayAlphaKitPayRetFailedCode):@(QBPayResultFailure),
                                           @(IapppayAlphaKitPayRetCancelCode):@(QBPayResultCancelled)};
    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
    if (!paymentResult) {
        paymentResult = @(QBPayResultUnknown);
    }

    NSString *signature = [resultInfo objectForKey:@"Signature"];
    if (paymentResult.unsignedIntegerValue == QBPayResultSuccess) {
        if (![IapppayAlphaOrderUtils checkPayResult:signature withAppKey:self.publicKey]) {
            QBLog(@"支付成功，但是延签失败！");
            paymentResult = @(QBPayResultFailure);
        }
    }
    QBSafelyCallBlock(self.completionHandler, paymentResult.unsignedIntegerValue, self.paymentInfo);
    self.completionHandler = nil;
    self.paymentInfo = nil;
}
@end
