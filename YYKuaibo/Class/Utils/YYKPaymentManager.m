//
//  YYKPaymentManager.m
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "YYKPaymentManager.h"
#import "YYKPaymentInfo.h"
#import "YYKPaymentViewController.h"
#import "YYKProgram.h"
#import "YYKPaymentConfigModel.h"

#import "WXApi.h"
#import "WeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
#import <IapppayAlphaKit/IapppayAlphaKit.h>

static NSString *const kAlipaySchemeUrl = @"comyykuaibo2016appalipayurlscheme";

@interface YYKPaymentManager () <IapppayAlphaKitPayRetDelegate,WXApiDelegate>
@property (nonatomic,retain) YYKPaymentInfo *paymentInfo;
@property (nonatomic,copy) YYKPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) WeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@end

@implementation YYKPaymentManager

DefineLazyPropertyInitialization(WeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

+ (instancetype)sharedManager {
    static YYKPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
    [[YYKPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        [[IapppayAlphaKit sharedInstance] setAppAlipayScheme:kAlipaySchemeUrl];
        [[IapppayAlphaKit sharedInstance] setAppId:[YYKPaymentConfig sharedConfig].iappPayInfo.appid mACID:YYK_CHANNEL_NO];
        [WXApi registerApp:[YYKPaymentConfig sharedConfig].weixinInfo.appId];
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
    [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)startPaymentWithType:(YYKPaymentType)type
                     subType:(YYKPaymentType)subType
                       price:(NSUInteger)price
                  forProgram:(YYKProgram *)program
           completionHandler:(YYKPaymentCompletionHandler)handler
{
    if (type == YYKPaymentTypeNone || (type == YYKPaymentTypeIAppPay && subType == YYKPaymentTypeNone)) {
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, nil);
        }
        return NO;
    }
    
    NSString *channelNo = YYK_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    YYKPaymentInfo *paymentInfo = [[YYKPaymentInfo alloc] init];
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @(price);
    paymentInfo.contentId = program.programId;
    paymentInfo.contentType = program.type;
    paymentInfo.payPointType = program.payPointType;
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(YYKPaymentStatusPaying);
    paymentInfo.reservedData = [YYKUtil paymentReservedData];
    if (type == YYKPaymentTypeWeChatPay) {
        paymentInfo.appId = [YYKPaymentConfig sharedConfig].weixinInfo.appId;
        paymentInfo.mchId = [YYKPaymentConfig sharedConfig].weixinInfo.mchId;
        paymentInfo.signKey = [YYKPaymentConfig sharedConfig].weixinInfo.signKey;
        paymentInfo.notifyUrl = [YYKPaymentConfig sharedConfig].weixinInfo.notifyUrl;
    }
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = handler;
    
    BOOL success = YES;
    if (type == YYKPaymentTypeWeChatPay) {
        @weakify(self);
        [[WeChatPayManager sharedInstance] startWithPayment:paymentInfo completionHandler:^(PAYRESULT payResult) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
    } else if (type == YYKPaymentTypeIAppPay) {
        NSDictionary *paymentTypeMapping = @{@(YYKPaymentTypeAlipay):@(IapppayAlphaKitAlipayPayType),
                                             @(YYKPaymentTypeWeChatPay):@(IapppayAlphaKitWeChatPayType)};
        NSNumber *payType = paymentTypeMapping[@(subType)];
        if (!payType) {
            return NO;
        }
        
        IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
        order.appId = [YYKPaymentConfig sharedConfig].iappPayInfo.appid;
        order.cpPrivateKey = [YYKPaymentConfig sharedConfig].iappPayInfo.privateKey;
        order.cpOrderId = orderNo;
#ifdef DEBUG
        order.waresId = @"2";
#else
        order.waresId = [YYKPaymentConfig sharedConfig].iappPayInfo.waresid;
#endif
        order.price = [NSString stringWithFormat:@"%.2f", price/100.];
        order.appUserId = [YYKUtil userId] ?: @"UnregisterUser";
        order.cpPrivateInfo = YYK_PAYMENT_RESERVE_DATA;
        
        NSString *trandData = [order getTrandData];
        success = [[IapppayAlphaKit sharedInstance] makePayForTrandInfo:trandData
                                                          payMethodType:payType.unsignedIntegerValue
                                                            payDelegate:self];
    } else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, self.paymentInfo);
        }
    }
    
    return success;
}

- (void)checkPayment {
    NSArray<YYKPaymentInfo *> *payingPaymentInfos = [YYKUtil payingPaymentInfos];
    [payingPaymentInfos enumerateObjectsUsingBlock:^(YYKPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YYKPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
        if (paymentType == YYKPaymentTypeWeChatPay) {
            if (obj.appId.length == 0 || obj.mchId.length == 0 || obj.signKey.length == 0 || obj.notifyUrl.length == 0) {
                obj.appId = [YYKPaymentConfig sharedConfig].weixinInfo.appId;
                obj.mchId = [YYKPaymentConfig sharedConfig].weixinInfo.mchId;
                obj.signKey = [YYKPaymentConfig sharedConfig].weixinInfo.signKey;
                obj.notifyUrl = [YYKPaymentConfig sharedConfig].weixinInfo.notifyUrl;
            }
            
            [self.wechatPayOrderQueryRequest queryPayment:obj withCompletionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    YYKPaymentViewController *paymentVC = [YYKPaymentViewController sharedPaymentVC];
                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
                }
            }];
        }
    }];
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
    
    if (self.completionHandler) {
        self.completionHandler(paymentResult.integerValue, self.paymentInfo);
    }
}

#pragma mark - WeChat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PAYRESULT payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = PAYRESULT_ABANDON;
        } else if (resp.errCode == WXSuccess) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}
@end
