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
#import "YYKPaymentConfigModel.h"

#import "WXApi.h"
#import "WeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import "PayUtils.h"
#import "paySender.h"

#import "SPayUtil.h"
//
//#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
//#import <IapppayAlphaKit/IapppayAlphaKit.h>

//static NSString *const kAlipaySchemeUrl = @"comyykuaibo2016appalipayurlscheme";
static NSString *const kVIAPaySchemeUrl = @"comyykuaibov2appviapayurlscheme";

@interface YYKPaymentManager () <WXApiDelegate, stringDelegate>
@property (nonatomic,retain) YYKPaymentInfo *paymentInfo;
@property (nonatomic,copy) YYKPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) WeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@property (nonatomic,retain) YYKProgram *payProgram;
@property (nonatomic,retain) YYKChannel *payChannel;
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
    [[PayUitls getIntents] initSdk];
    [paySender getIntents].delegate = self;
    
    [[YYKPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        
        [[SPayUtil sharedInstance] registerMchId:[YYKPaymentConfig sharedConfig].wftPayInfo.mchId
                                         signKey:[YYKPaymentConfig sharedConfig].wftPayInfo.signKey
                                       notifyUrl:[YYKPaymentConfig sharedConfig].wftPayInfo.notifyUrl];
    }];
    
}

- (void)handleOpenUrl:(NSURL *)url {
    [[PayUitls getIntents] paytoAli:url];
}

- (YYKPaymentInfo *)startPaymentWithType:(YYKPaymentType)type
                                 subType:(YYKPaymentType)subType
                                   price:(NSUInteger)price
                            payPointType:(YYKPayPointType)payPointType
                              forProgram:(YYKProgram *)program
                         programLocation:(NSUInteger)programLocation
                               inChannel:(YYKChannel *)channel
                       completionHandler:(YYKPaymentCompletionHandler)handler
{
    if (type == YYKPaymentTypeNone || (type == YYKPaymentTypeIAppPay && subType == YYKPaymentTypeNone)) {
        if (handler) {
            handler(PAYRESULT_FAIL, nil);
        }
        return nil;
    }
    
#ifdef DEBUG
    if (payPointType == YYKPayPointTypeSVIP) {
        price = 2;
    } else {
        price = 1;
    }
#endif
    
    NSString *channelNo = YYK_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    YYKPaymentInfo *paymentInfo = [[YYKPaymentInfo alloc] init];
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @(price);
    paymentInfo.contentId = program.programId;
    paymentInfo.contentType = program.type;
    paymentInfo.contentLocation = @(programLocation+1);
    paymentInfo.columnId = channel.realColumnId;
    paymentInfo.columnType = channel.type;
    paymentInfo.payPointType = payPointType == YYKPayPointTypeSVIP ? @(YYKPayPointTypeSVIP) : @(YYKPayPointTypeVIP);
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(YYKPaymentStatusPaying);
    paymentInfo.reservedData = [YYKUtil paymentReservedData];
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = handler;
    self.payProgram = program;
    self.payChannel = channel;
    
    BOOL success = YES;
    if (type == YYKPaymentTypeVIAPay && (subType == YYKPaymentTypeAlipay || subType == YYKPaymentTypeWeChatPay)) {
        NSString *tradeName = program.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP ? @"黑钻VIP会员" : @"VIP会员";
        [[PayUitls getIntents]   gotoPayByFee:@(price).stringValue
                                 andTradeName:tradeName
                              andGoodsDetails:tradeName
                                    andScheme:kVIAPaySchemeUrl
                            andchannelOrderId:[orderNo stringByAppendingFormat:@"$%@", YYK_REST_APP_ID]
                                      andType:subType == YYKPaymentTypeAlipay ? @"1" : @"2"
                             andViewControler:[YYKUtil currentVisibleViewController]];
//    if (type == YYKPaymentTypeWeChatPay) {
//        @weakify(self);
//        [[WeChatPayManager sharedInstance] startWithPayment:paymentInfo completionHandler:^(PAYRESULT payResult) {
//            @strongify(self);
//            if (self.completionHandler) {
//                self.completionHandler(payResult, self.paymentInfo);
//            }
//        }];
//    } else if (type == YYKPaymentTypeIAppPay) {
//        NSDictionary *paymentTypeMapping = @{@(YYKPaymentTypeAlipay):@(IapppayAlphaKitAlipayPayType),
//                                             @(YYKPaymentTypeWeChatPay):@(IapppayAlphaKitWeChatPayType)};
//        NSNumber *payType = paymentTypeMapping[@(subType)];
//        if (!payType) {
//            return NO;
//        }
//        
//        IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
//        order.appId = [YYKPaymentConfig sharedConfig].iappPayInfo.appid;
//        order.cpPrivateKey = [YYKPaymentConfig sharedConfig].iappPayInfo.privateKey;
//        order.cpOrderId = orderNo;
//#ifdef DEBUG
//        order.waresId = @"2";
//#else
//        order.waresId = [YYKPaymentConfig sharedConfig].iappPayInfo.waresid.stringValue;
//#endif
//        order.price = [NSString stringWithFormat:@"%.2f", price/100.];
//        order.appUserId = [YYKUtil userId] ?: @"UnregisterUser";
//        order.cpPrivateInfo = YYK_PAYMENT_RESERVE_DATA;
//        
//        NSString *trandData = [order getTrandData];
//        success = [[IapppayAlphaKit sharedInstance] makePayForTrandInfo:trandData
//                                                          payMethodType:payType.unsignedIntegerValue
//                                                            payDelegate:self];
    } else if (type == YYKPaymentTypeSPay && (subType == YYKPaymentTypeAlipay || subType == YYKPaymentTypeWeChatPay)) {
        @weakify(self);
        [[SPayUtil sharedInstance] payWithPaymentInfo:paymentInfo completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
            @strongify(self);
            [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
            
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
    } else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, self.paymentInfo);
        }
    }
    
    return success ? paymentInfo : nil;
}

//- (void)checkPayment {
//    NSArray<YYKPaymentInfo *> *payingPaymentInfos = [YYKUtil payingPaymentInfos];
//    [payingPaymentInfos enumerateObjectsUsingBlock:^(YYKPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        YYKPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
//        if (paymentType == YYKPaymentTypeWeChatPay) {
//            if (obj.appId.length == 0 || obj.mchId.length == 0 || obj.signKey.length == 0 || obj.notifyUrl.length == 0) {
//                obj.appId = [YYKPaymentConfig sharedConfig].weixinInfo.appId;
//                obj.mchId = [YYKPaymentConfig sharedConfig].weixinInfo.mchId;
//                obj.signKey = [YYKPaymentConfig sharedConfig].weixinInfo.signKey;
//                obj.notifyUrl = [YYKPaymentConfig sharedConfig].weixinInfo.notifyUrl;
//            }
//            
//            [self.wechatPayOrderQueryRequest queryPayment:obj withCompletionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
//                if ([trade_state isEqualToString:@"SUCCESS"]) {
//                    YYKPaymentViewController *paymentVC = [YYKPaymentViewController sharedPaymentVC];
//                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
//                    [self onPaymentResult:PAYRESULT_SUCCESS];
//                }
//            }];
//        }
//    }];
//}

- (void)applicationWillEnterForeground {
    [[SPayUtil sharedInstance] applicationWillEnterForeground];
}

- (void)onPaymentResult:(PAYRESULT)payResult withPaymentInfo:(YYKPaymentInfo *)paymentInfo {
    if (payResult == PAYRESULT_SUCCESS) {
        [[YYKLocalNotificationManager sharedManager] cancelAllNotifications];
    }
}

//#pragma mark - IapppayAlphaKitPayRetDelegate
//
//- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode resultInfo:(NSDictionary *)resultInfo {
//    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(PAYRESULT_SUCCESS),
//                                           @(IapppayAlphaKitPayRetFailedCode):@(PAYRESULT_FAIL),
//                                           @(IapppayAlphaKitPayRetCancelCode):@(PAYRESULT_ABANDON)};
//    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
//    if (!paymentResult) {
//        paymentResult = @(PAYRESULT_UNKNOWN);
//    }
//    
//    [self onPaymentResult:paymentResult.integerValue];
//    
//    if (self.completionHandler) {
//        self.completionHandler(paymentResult.integerValue, self.paymentInfo);
//    }
//}

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
        [self onPaymentResult:payResult withPaymentInfo:self.paymentInfo];
    }
}

#pragma mark - stringDelegate

- (void)getResult:(NSDictionary *)sender {
    PAYRESULT paymentResult = [sender[@"result"] integerValue] == 0 ? PAYRESULT_SUCCESS : PAYRESULT_FAIL;
    
    [self onPaymentResult:paymentResult withPaymentInfo:self.paymentInfo];
    
    if (self.completionHandler) {
        if ([NSThread currentThread].isMainThread) {
            self.completionHandler(paymentResult, self.paymentInfo);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionHandler(paymentResult, self.paymentInfo);
            });
        }
    }
}
@end
