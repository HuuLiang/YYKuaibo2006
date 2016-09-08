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

//#import "WXApi.h"
//#import "WeChatPayQueryOrderRequest.h"
//#import "WeChatPayManager.h"

#import <PayUtil/PayUtil.h>

#import "IappPayMananger.h"
#import "MingPayManager.h"
//#import "SPayUtil.h"
#import "HTPayManager.h"

//static NSString *const kAlipaySchemeUrl = @"comyykuaibo2016appalipayurlscheme";
static NSString *const kVIAPaySchemeUrl = @"comqskuaiboappviapayurlscheme";
static NSString *const kIappPaySchemeUrl = @"comqskuaiboappiapppayurlscheme";

typedef NS_ENUM(NSUInteger, YYKVIAPayType) {
    YYKVIAPayTypeNone,
    YYKVIAPayTypeWeChat = 2,
    YYKVIAPayTypeQQ = 3,
    YYKVIAPayTypeUPPay = 4,
    YYKVIAPayTypeShenZhou = 5
};

@interface YYKPaymentManager () <stringDelegate>
@property (nonatomic,retain) YYKPaymentInfo *paymentInfo;
@property (nonatomic,copy) YYKPaymentCompletionHandler completionHandler;
//@property (nonatomic,retain) WeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@property (nonatomic,retain) YYKProgram *payProgram;
@property (nonatomic,retain) YYKChannel *payChannel;
@end

@implementation YYKPaymentManager

//DefineLazyPropertyInitialization(WeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

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
        if ([YYKPaymentConfig sharedConfig].configDetails.mingPayConfig) {
            [MingPayManager sharedManager].mch = [YYKPaymentConfig sharedConfig].configDetails.mingPayConfig.mch;
            [MingPayManager sharedManager].payUrl = [YYKPaymentConfig sharedConfig].configDetails.mingPayConfig.payUrl;
            [MingPayManager sharedManager].queryOrderUrl = [YYKPaymentConfig sharedConfig].configDetails.mingPayConfig.queryOrderUrl;
        }
    }];
    [IappPayMananger sharedMananger].alipayURLScheme = kIappPaySchemeUrl;
    
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
    return [YYKPaymentConfig sharedConfig].wechatPaymentType;
}

- (YYKPaymentType)alipayPaymentType {
    return [YYKPaymentConfig sharedConfig].alipayPaymentType;
}

- (YYKPaymentType)cardPayPaymentType {
//    if ([YYKPaymentConfig sharedConfig].iappPayInfo) {
//        return YYKPaymentTypeIAppPay;
//    }
    return YYKPaymentTypeNone;
}

- (YYKPaymentType)qqPaymentType {
    return [YYKPaymentConfig sharedConfig].qqPaymentType;
}

- (void)handleOpenUrl:(NSURL *)url {
    if ([url.absoluteString rangeOfString:kIappPaySchemeUrl].location == 0) {
        [[IappPayMananger sharedMananger] handleOpenURL:url];
    } else if ([url.absoluteString rangeOfString:kVIAPaySchemeUrl].location == 0) {
        [[PayUitls getIntents] paytoAli:url];
    }
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
    if (type == YYKPaymentTypeIAppPay || type == YYKPaymentTypeHTPay) {
        if (payPointType == YYKPayPointTypeSVIP) {
            price = 210;
        } else {
            price = 200;
        }
    } else if (type == YYKPaymentTypeMingPay) {
        if (payPointType == YYKPayPointTypeSVIP) {
            price = 110;
        } else {
            price = 100;
        }
    } else {
        price = payPointType == YYKPayPointTypeSVIP ? 2 : 1;
    }
    
#endif
    
    NSString *channelNo = YYK_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    YYKPaymentInfo *paymentInfo = [[YYKPaymentInfo alloc] init];
    if (type == YYKPaymentTypeMingPay) {
        paymentInfo.orderId = [[MingPayManager sharedManager] processOrderNo:orderNo];
    } else {
        paymentInfo.orderId = orderNo;
    }
    
    paymentInfo.orderPrice = @(price);
    
    NSString *tradeName = program.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP ? [kSVIPText stringByAppendingString:@"会员"] : @"VIP会员";
    NSString *contactName = [YYKSystemConfigModel sharedModel].contactName;
    if (type == YYKPaymentTypeMingPay) {
        paymentInfo.orderDescription = contactName ?: @"VIP";
    } else {
//        if (type == YYKPaymentTypeSPay) {
//            contactName = @"客服热线：4008079233";
//        }
        paymentInfo.orderDescription = contactName.length > 0 ? [tradeName stringByAppendingFormat:@"(%@)", contactName] : tradeName;
    }
    
    paymentInfo.contentId = program.programId;
    paymentInfo.contentType = program.type;
    paymentInfo.contentLocation = @(programLocation+1);
    paymentInfo.columnId = channel.realColumnId;
    paymentInfo.columnType = channel.type;
    paymentInfo.payPointType = payPointType == YYKPayPointTypeSVIP ? @(YYKPayPointTypeSVIP) : @(YYKPayPointTypeVIP);
    paymentInfo.paymentTime = [YYKUtil currentTimeString];
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentSubType = @(subType);
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
        YYKIAppPayConfig *payConfig = [YYKPaymentConfig sharedConfig].configDetails.iAppPayConfig;
        IappPayMananger *iAppMgr = [IappPayMananger sharedMananger];
        iAppMgr.appId = payConfig.appid;
        iAppMgr.privateKey = payConfig.privateKey;
        iAppMgr.waresid = payConfig.waresid.stringValue;
        iAppMgr.appUserId = [YYKUtil userId] ?: @"UnregisterUser";
        iAppMgr.privateInfo = YYK_PAYMENT_RESERVE_DATA;
        iAppMgr.notifyUrl = payConfig.notifyUrl;
        iAppMgr.publicKey = payConfig.publicKey;
        
        [iAppMgr payWithPaymentInfo:paymentInfo payType:subType completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
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
    } else if (type == YYKPaymentTypeHTPay) {
        @weakify(self);
        [HTPayManager sharedManager].mchId = [YYKPaymentConfig sharedConfig].configDetails.htpayConfig.mchId;
        [HTPayManager sharedManager].key = [YYKPaymentConfig sharedConfig].configDetails.htpayConfig.key;
        [HTPayManager sharedManager].notifyUrl = [YYKPaymentConfig sharedConfig].configDetails.htpayConfig.notifyUrl;
        
        [[HTPayManager sharedManager] payWithPaymentInfo:paymentInfo
                                       completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo)
        {
            @strongify(self);
            [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
            
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
    } else if (type == YYKPaymentTypeMingPay) {
        @weakify(self);
        [[MingPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
            @strongify(self);
            [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
            
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
//    } else if (type == YYKPaymentTypeSPay) {
//        @weakify(self);
//        YYKSPayConfig *payConfig = [YYKPaymentConfig sharedConfig].configDetails.spayConfig;
//        
//        [[SPayUtil sharedInstance] registerMchId:payConfig.mchId
//                                         signKey:payConfig.signKey
//                                       notifyUrl:payConfig.notifyUrl];
//        [[SPayUtil sharedInstance] payWithPaymentInfo:paymentInfo completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
//            @strongify(self);
//            [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
//            
//            if (self.completionHandler) {
//                self.completionHandler(payResult, self.paymentInfo);
//            }
//        }];
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
