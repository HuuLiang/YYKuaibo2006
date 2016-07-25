//
//  YYKPaymentManager.m
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "YYKPaymentManager.h"
#import "YYKPaymentInfo.h"
#import "YYKSystemConfigModel.h"
#import "YYKPaymentConfigModel.h"

#import "WXApi.h"
#import "WeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import <PayUtil/PayUtil.h>

#import "IappPayMananger.h"

//static NSString *const kAlipaySchemeUrl = @"comyykuaibo2016appalipayurlscheme";
static NSString *const kVIAPaySchemeUrl = @"comyykuaibov27appviapayurlscheme";

typedef NS_ENUM(NSUInteger, YYKVIAPayType) {
    YYKVIAPayTypeNone,
    YYKVIAPayTypeWeChat = 2,
    YYKVIAPayTypeQQ = 3,
    YYKVIAPayTypeUPPay = 4,
    YYKVIAPayTypeShenZhou = 5
};

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
    
    [[YYKPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:nil];
    
    Class class = NSClassFromString(@"VIASZFViewController");
    if (class) {
        [class aspect_hookSelector:NSSelectorFromString(@"viewWillAppear:")
                       withOptions:AspectPositionAfter
                        usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated)
        {
            UIViewController *thisVC = [aspectInfo instance];
            if ([thisVC respondsToSelector:NSSelectorFromString(@"buy")]) {
                UIViewController *buyVC = [thisVC valueForKey:@"buy"];
                [buyVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[UIButton class]]) {
                        UIButton *buyButton = (UIButton *)obj;
                        if ([[buyButton titleForState:UIControlStateNormal] isEqualToString:@"购卡支付"]) {
                            [buyButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                }];
            }
        } error:nil];
    }
    
}

- (YYKPaymentType)wechatPaymentType {
    if ([YYKPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & YYKSubPayTypeWeChat) {
        return YYKPaymentTypeVIAPay;
//    } else if ([YYKPaymentConfig sharedConfig].wftPayInfo) {
//        return YYKPaymentTypeSPay;
//    } else if ([YYKPaymentConfig sharedConfig].haitunPayInfo) {
//        return YYKPaymentTypeHTPay;
    }
    return YYKPaymentTypeNone;
}

- (YYKPaymentType)alipayPaymentType {
    if ([YYKPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & YYKSubPayTypeAlipay) {
        return YYKPaymentTypeVIAPay;
    }
    return YYKPaymentTypeNone;
}

- (YYKPaymentType)cardPayPaymentType {
    if ([YYKPaymentConfig sharedConfig].iappPayInfo) {
        return YYKPaymentTypeIAppPay;
    }
    return YYKPaymentTypeNone;
}

- (YYKPaymentType)qqPaymentType {
    if ([YYKPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.unsignedIntegerValue & YYKSubPayTypeQQ) {
        return YYKPaymentTypeVIAPay;
    }
    return YYKPaymentTypeNone;
}

- (void)handleOpenUrl:(NSURL *)url {
    [[PayUitls getIntents] paytoAli:url];
}

- (YYKPaymentInfo *)startPaymentWithType:(YYKPaymentType)type
                                 subType:(YYKSubPayType)subType
                                   price:(NSUInteger)price
                            payPointType:(YYKPayPointType)payPointType
                              forProgram:(YYKProgram *)program
                         programLocation:(NSUInteger)programLocation
                               inChannel:(YYKChannel *)channel
                       completionHandler:(YYKPaymentCompletionHandler)handler
{
    if (type == YYKPaymentTypeNone) {
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
    paymentInfo.paymentTime = [YYKUtil currentTimeString];
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
    if (type == YYKPaymentTypeVIAPay && (subType == YYKSubPayTypeAlipay || subType == YYKSubPayTypeWeChat || subType == YYKSubPayTypeQQ)) {
        NSDictionary *viaPayTypeMapping = @{@(YYKSubPayTypeAlipay):@(YYKVIAPayTypeShenZhou),
                                            @(YYKSubPayTypeWeChat):@(YYKVIAPayTypeWeChat),
                                            @(YYKSubPayTypeQQ):@(YYKVIAPayTypeQQ)};
        
        NSString *tradeName = program.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP ? [kSVIPText stringByAppendingString:@"会员"] : @"VIP会员";
        [[PayUitls getIntents]   gotoPayByFee:@(price).stringValue
                                 andTradeName:tradeName
                              andGoodsDetails:tradeName
                                    andScheme:kVIAPaySchemeUrl
                            andchannelOrderId:[orderNo stringByAppendingFormat:@"$%@", YYK_REST_APP_ID]
                                      andType:[viaPayTypeMapping[@(subType)] stringValue]
                             andViewControler:[YYKUtil currentVisibleViewController]];
//    } else if (type == YYKPaymentTypeSPay && (subType == YYKSubPayTypeAlipay || subType == YYKSubPayTypeWeChat)) {
//        @weakify(self);
//        paymentInfo.reservedData = [NSString stringWithFormat:@"客服电话：%@", [YYKSystemConfigModel sharedModel].contact];
//        [[SPayUtil sharedInstance] payWithPaymentInfo:paymentInfo completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
//            @strongify(self);
//            [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
//            
//            if (self.completionHandler) {
//                self.completionHandler(payResult, self.paymentInfo);
//            }
//        }];
    } else if (type == YYKPaymentTypeIAppPay) {
        @weakify(self);
        IappPayMananger *iAppMgr = [IappPayMananger sharedMananger];
        iAppMgr.appId = [YYKPaymentConfig sharedConfig].iappPayInfo.appid;
        iAppMgr.privateKey = [YYKPaymentConfig sharedConfig].iappPayInfo.privateKey;
        iAppMgr.waresid = [YYKPaymentConfig sharedConfig].iappPayInfo.waresid.stringValue;
        iAppMgr.appUserId = [YYKUtil userId].md5 ?: @"UnregisterUser";
        iAppMgr.privateInfo = YYK_PAYMENT_RESERVE_DATA;
        iAppMgr.notifyUrl = [YYKPaymentConfig sharedConfig].iappPayInfo.notifyUrl;
        iAppMgr.publicKey = [YYKPaymentConfig sharedConfig].iappPayInfo.publicKey;
        
        [iAppMgr payWithPaymentInfo:paymentInfo completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
            @strongify(self);
            [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
            
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
//    } else if (type == YYKPaymentTypeHTPay && subType == YYKSubPayTypeWeChat) {
//        @weakify(self);
//        [[HTPayManager sharedManager] payWithOrderId:orderNo
//                                           orderName:program.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP ? [kSVIPText stringByAppendingString:@"会员"] : @"VIP会员"
//                                               price:price
//                               withCompletionHandler:^(BOOL success, id obj)
//         {
//             @strongify(self);
//             PAYRESULT payResult = success ? PAYRESULT_SUCCESS : PAYRESULT_FAIL;
//             [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
//             
//             if (self.completionHandler) {
//                 self.completionHandler(payResult, self.paymentInfo);
//             }
//         }];
    } else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, self.paymentInfo);
        }
    }
    return success ? paymentInfo : nil;
}

- (void)applicationWillEnterForeground {
//    [[SPayUtil sharedInstance] applicationWillEnterForeground];
}

- (void)onPaymentResult:(PAYRESULT)payResult withPaymentInfo:(YYKPaymentInfo *)paymentInfo {
    if (payResult == PAYRESULT_SUCCESS && [YYKSystemConfigModel sharedModel].notificationLaunchSeq > 0) {
        [[YYKLocalNotificationManager sharedManager] cancelAllNotifications];
    }
}

#pragma mark - stringDelegate

- (void)getResult:(NSDictionary *)sender {
    PAYRESULT paymentResult = [sender[@"result"] integerValue] == 0 ? PAYRESULT_SUCCESS : PAYRESULT_FAIL;
    if (paymentResult == PAYRESULT_FAIL) {
        DLog(@"首游时空支付失败：%@", sender[@"info"]);
//    } else if (paymentResult == PAYRESULT_SUCCESS) {
//        UIViewController *currentController = [YYKUtil currentVisibleViewController];
//        if ([currentController isKindOfClass:NSClassFromString(@"SZFViewController")]) {
//            [currentController dismissViewControllerAnimated:YES completion:nil];
//        }
    }
    
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
