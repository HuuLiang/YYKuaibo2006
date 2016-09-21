//
//  QBPaymentManager.m
//  QBPayment
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "QBPaymentManager.h"
#import "QBPaymentNetworkingConfiguration.h"
#import "QBPaymentInfo.h"
#import "QBDefines.h"
#import "NSString+md5.h"
#import "RACEXTScope.h"
#import "QBPaymentConfig.h"
#import "Aspects.h"

//#import "QBSystemConfigModel.h"
#import "QBPaymentConfigModel.h"
#import "QBPaymentCommitModel.h"
#import "QBOrderQueryModel.h"

#ifdef QBPAYMENT_VIAPAY_ENABLED
    #import <PayUtil/PayUtil.h>
#endif
//#import <WYPay/WYPayManager.h>

#ifdef QBPAYMENT_IAPPPAY_ENABLED
    #import "IappPayMananger.h"
#endif

#ifdef QBPAYMENT_DXTXPAY_ENABLED
    #import "PayuPlugin.h"
#endif

#ifdef QBPAYMENT_HTPAY_ENABLED
    #import "HTPayManager.h"
#endif

#ifdef QBPAYMENT_WFTPAY_ENABLED
    #import "SPayUtil.h"
#endif
//#import "MingPayManager.h"
//#import "SPayUtil.h"
//#import "HTPayManager.h"

typedef NS_ENUM(NSUInteger, QBVIAPayType) {
    QBVIAPayTypeNone,
    QBVIAPayTypeWeChat = 2,
    QBVIAPayTypeQQ = 3,
    QBVIAPayTypeUPPay = 4,
    QBVIAPayTypeShenZhou = 5
};

NSString *const kQBPaymentFetchConfigNotification = @"com.qbpayment.app.config";

@interface QBPaymentManager ()
#ifdef QBPAYMENT_VIAPAY_ENABLED
<stringDelegate>
#endif
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) QBPaymentConfigModel *configModel;
@property (nonatomic,retain) QBPaymentCommitModel *commitModel;
@property (nonatomic,retain) QBOrderQueryModel *orderQueryModel;
@property (nonatomic) NSString *urlScheme;
@end

@implementation QBPaymentManager

QBDefineLazyPropertyInitialization(QBPaymentConfigModel, configModel)
QBDefineLazyPropertyInitialization(QBPaymentCommitModel, commitModel)
QBDefineLazyPropertyInitialization(QBOrderQueryModel, orderQueryModel)

+ (instancetype)sharedManager {
    static QBPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
#ifdef QBPAYMENT_VIAPAY_ENABLED
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
#endif
    }
    return self;
}

- (void)registerPaymentWithAppId:(NSString *)appId paymentPv:(NSNumber *)pv channelNo:(NSString *)channelNo urlScheme:(NSString *)urlScheme {
    [QBPaymentNetworkingConfiguration defaultConfiguration].RESTAppId = appId;
    [QBPaymentNetworkingConfiguration defaultConfiguration].RESTpV = pv;
    [QBPaymentNetworkingConfiguration defaultConfiguration].channelNo = channelNo;
    self.urlScheme = urlScheme;
    
#ifdef QBPAYMENT_VIAPAY_ENABLED
    [[PayUitls getIntents] initSdk];
    [paySender getIntents].delegate = self;
#endif
    
#ifdef QBPAYMENT_IAPPPAY_ENABLED
    [IappPayMananger sharedMananger].alipayURLScheme = urlScheme;
#endif
    
    [self refreshAvailablePaymentTypesWithCompletionHandler:nil];
    
    [self.commitModel startRetryingToCommitUnprocessedOrders];
}

- (void)refreshAvailablePaymentTypesWithCompletionHandler:(void (^)(void))completionHandler {
    [self.configModel fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        //        if ([QBPaymentConfig sharedConfig].configDetails.mingPayConfig) {
        //            [MingPayManager sharedManager].mch = [QBPaymentConfig sharedConfig].configDetails.mingPayConfig.mch;
        //            [MingPayManager sharedManager].payUrl = [QBPaymentConfig sharedConfig].configDetails.mingPayConfig.payUrl;
        //            [MingPayManager sharedManager].queryOrderUrl = [QBPaymentConfig sharedConfig].configDetails.mingPayConfig.queryOrderUrl;
        //        }
        //
#ifdef QBPAYMENT_HTPAY_ENABLED
        if ([QBPaymentConfig sharedConfig].configDetails.htpayConfig) {
            [HTPayManager sharedManager].mchId = [QBPaymentConfig sharedConfig].configDetails.htpayConfig.mchId;
            [HTPayManager sharedManager].key = [QBPaymentConfig sharedConfig].configDetails.htpayConfig.key;
            [HTPayManager sharedManager].notifyUrl = [QBPaymentConfig sharedConfig].configDetails.htpayConfig.notifyUrl;
            [[HTPayManager sharedManager] setup];
        }
#endif
        
#ifdef QBPAYMENT_DXTXPAY_ENABLED
        if ([QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig) {
            [[PayuPlugin defaultPlugin] registWithAppKey:[QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig.appKey];
        }
#endif
        
#ifdef QBPAYMENT_WFTPAY_ENABLED
        QBSPayConfig *payConfig = [QBPaymentConfig sharedConfig].configDetails.spayConfig;
        if (payConfig) {
            [[SPayUtil sharedInstance] registerMchId:payConfig.mchId
                                             signKey:payConfig.signKey
                                           notifyUrl:payConfig.notifyUrl];
        }

#endif
        QBSafelyCallBlock(completionHandler);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kQBPaymentFetchConfigNotification object:nil];
    }];
}

- (QBPayType)wechatPaymentType {
    return [QBPaymentConfig sharedConfig].wechatPaymentType;
}

- (QBPayType)alipayPaymentType {
    return [QBPaymentConfig sharedConfig].alipayPaymentType;
}

- (QBPayType)cardPayPaymentType {
//    if ([QBPaymentConfig sharedConfig].iappPayInfo) {
//        return QBPayTypeIAppPay;
//    }
    return QBPayTypeNone;
}

- (QBPayType)qqPaymentType {
    return [QBPaymentConfig sharedConfig].qqPaymentType;
}

- (BOOL)IsSDKIntegratedForPayType:(QBPayType)payType {
//    QBPayTypeIAppPay = 1009, //爱贝支付
//    QBPayTypeVIAPay = 1010, //首游时空
//    QBPayTypeSPay = 1012, //威富通
//    QBPayTypeHTPay = 1015, //海豚支付
//    QBPayTypeMingPay = 1018, //明鹏支付
//    QBPayTypeDXTXPay = 1019, //盾行天下
//    QBPayTypeWeiYingPay = 1022, //微赢支付
    if (payType == QBPayTypeIAppPay) {
#ifdef QBPAYMENT_IAPPPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeVIAPay) {
#ifdef QBPAYMENT_VIAPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeSPay) {
#ifdef QBPAYMENT_WFTPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeHTPay) {
#ifdef QBPAYMENT_HTPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeMingPay) {
#ifdef QBPAYMENT_MINGPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeDXTXPay) {
#ifdef QBPAYMENT_DXTXPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeWeiYingPay) {
#ifdef QBPAYMENT_WEIYINGPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    }
    return NO;
}

- (void)handleOpenUrl:(NSURL *)url {
    if (self.paymentInfo.paymentType == QBPayTypeIAppPay) {
#ifdef QBPAYMENT_IAPPPAY_ENABLED
        [[IappPayMananger sharedMananger] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeVIAPay) {
#ifdef QBPAYMENT_VIAPAY_ENABLED
        [[PayUitls getIntents] paytoAli:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeDXTXPay) {
#ifdef QBPAYMENT_DXTXPAY_ENABLED
        [[PayuPlugin defaultPlugin] processOrderWithPaymentResult:url];
#endif
    }
}

- (BOOL)startPaymentWithPaymentInfo:(QBPaymentInfo *)paymentInfo
                  completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (paymentInfo.paymentType == QBPayTypeNone || paymentInfo.orderId.length == 0 || paymentInfo.orderPrice == 0) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return NO;
    }
    
    NSUInteger price = paymentInfo.orderPrice;
    QBPayPointType payPointType = paymentInfo.payPointType;
    QBPayType payType = paymentInfo.paymentType;
    QBPaySubType subType = paymentInfo.paymentSubType;
    
//#ifdef DEBUG
//    if (payType == QBPayTypeIAppPay || payType == QBPayTypeHTPay || payType == QBPayTypeWeiYingPay)
//    {
//        if (payPointType == QBPayPointTypeSVIP) {
//            price = 210;
//        } else {
//            price = 200;
//        }
//    } else if (payType == QBPayTypeMingPay || payType == QBPayTypeDXTXPay) {
//        if (payPointType == QBPayPointTypeSVIP) {
//            price = 110;
//        } else {
//            price = 100;
//        }
//    } else if (payType == QBPayTypeVIAPay) {
//        price = 1000;
//    } else {
//        price = payPointType == QBPayPointTypeSVIP ? 2 : 1;
//    }
//    
//#endif
    
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = completionHandler;
    
    @weakify(self);
    QBPaymentCompletionHandler paymentHandler = ^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
        @strongify(self);
        [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
        QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
    };
    
    BOOL success = NO;
#ifdef QBPAYMENT_VIAPAY_ENABLED
    if (payType == QBPayTypeVIAPay && (subType == QBPaySubTypeAlipay || subType == QBPaySubTypeWeChat || subType == QBPaySubTypeQQ)) {

        NSDictionary *viaPayTypeMapping = @{@(QBPaySubTypeAlipay):@(QBVIAPayTypeShenZhou),
                                            @(QBPaySubTypeWeChat):@(QBVIAPayTypeWeChat),
                                            @(QBPaySubTypeQQ):@(QBVIAPayTypeQQ)};
        
        [[PayUitls getIntents]   gotoPayByFee:@(price).stringValue
                                 andTradeName:paymentInfo.orderDescription
                              andGoodsDetails:paymentInfo.orderDescription
                                    andScheme:self.urlScheme
                            andchannelOrderId:[paymentInfo.orderId stringByAppendingFormat:@"$%@", [QBPaymentNetworkingConfiguration defaultConfiguration].RESTAppId]
                                      andType:[viaPayTypeMapping[@(subType)] stringValue]
                             andViewControler:[UIApplication sharedApplication].keyWindow.rootViewController];
        
        success = YES;
    }
#endif
//    } else if (type == QBPayTypeSPay && (subType == QBPaySubTypeAlipay || subType == QBPaySubTypeWeChat)) {
//        @weakify(self);
//        paymentInfo.reservedData = [NSString stringWithFormat:@"客服电话：%@", [QBSystemConfigModel sharedModel].contact];
//        [[SPayUtil sharedInstance] payWithPaymentInfo:paymentInfo completionHandler:^(PAYRESULT payResult, QBPaymentInfo *paymentInfo) {
//            @strongify(self);
//            [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
//            
//            if (self.completionHandler) {
//                self.completionHandler(payResult, self.paymentInfo);
//            }
//        }];
#ifdef QBPAYMENT_IAPPPAY_ENABLED
    if (payType == QBPayTypeIAppPay) {
        QBIAppPayConfig *payConfig = [QBPaymentConfig sharedConfig].configDetails.iAppPayConfig;
        IappPayMananger *iAppMgr = [IappPayMananger sharedMananger];
        iAppMgr.appId = payConfig.appid;
        iAppMgr.privateKey = payConfig.privateKey;
        iAppMgr.waresid = payConfig.waresid.stringValue;
        iAppMgr.appUserId = paymentInfo.userId ?: @"UnregisterUser";
        iAppMgr.privateInfo = paymentInfo.reservedData;
        iAppMgr.notifyUrl = payConfig.notifyUrl;
        iAppMgr.publicKey = payConfig.publicKey;
        
        [iAppMgr payWithPaymentInfo:paymentInfo payType:subType completionHandler:paymentHandler];
        
        success = YES;
    }
#endif

#ifdef QBPAYMENT_DXTXPAY_ENABLED
    if (payType == QBPayTypeDXTXPay && (subType == QBPaySubTypeWeChat || subType == QBPaySubTypeAlipay)) {
        NSNumber *goodsId = [QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig.waresid;
        NSString *appKey = [QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig.appKey;
        
//        UINavigationController *nav = [UIApplication sharedApplication].keyWindow.rootViewController;
//        [[PayuPlugin defaultPlugin] aspect_hookSelector:@selector(payWithWX:viewController:o_price:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, NSString *wx, UIViewController *viewController, double price){
//            
//        } error:nil];
//        
//        
//        [NSObject aspect_hookSelector:@selector(valueForKey:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, NSString *key){
//            id instance = [aspectInfo instance];
//            if (instance) {
//                
//            }
//        } error:nil];
        
        [[PayuPlugin defaultPlugin] payWithViewController:[UIApplication sharedApplication].keyWindow.rootViewController
                                             o_paymode_id:subType==QBPaySubTypeWeChat?PayTypeWX:PayTypeAliPay
                                                O_bizcode:paymentInfo.orderId
                                               o_goods_id:goodsId.intValue
                                             o_goods_name:paymentInfo.orderDescription
                                                  o_price:paymentInfo.orderPrice/100.
                                            o_privateinfo:paymentInfo.reservedData
                                                   Scheme:self.urlScheme
                                                   AppKey:appKey
                                            completeBlock:^(NSDictionary *result)
        {
            NSInteger code = [result[@"resultStatus"] integerValue];
            QBPayResult payResult = QBPayResultFailure;
            if (code == 6001) {
                payResult = QBPayResultCancelled;
            } else if (code == 9000) {
                payResult = QBPayResultSuccess;
            }
            paymentHandler(payResult, paymentInfo);
        }];
        
        success = YES;
    }
#endif
    
#ifdef QBPAYMENT_HTPAY_ENABLED
    if (payType == QBPayTypeHTPay) {
        [[HTPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
        
        success = YES;
    }
#endif
    
#ifdef QBPAYMENT_WFTPAY_ENABLED
    if (payType == QBPayTypeSPay) {
        [[SPayUtil sharedInstance] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
        
        success = YES;
    }
#endif
    
    if (!success) {
        paymentHandler(QBPayResultFailure, paymentInfo);
    }
    return success;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [WYPayManager heepaySDKWillEnterForeground];
//    [[SPayUtil sharedInstance] applicationWillEnterForeground];
#ifdef QBPAYMENT_DXTXPAY_ENABLED
    [[PayuPlugin defaultPlugin] applicationWillEnterForeground:application];
#endif
    
#ifdef QBPAYMENT_WFTPAY_ENABLED
    [[SPayUtil sharedInstance] applicationWillEnterForeground];
#endif
}

- (void)onPaymentResult:(QBPayResult)payResult withPaymentInfo:(QBPaymentInfo *)paymentInfo {
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    
    paymentInfo.paymentResult = payResult;
    paymentInfo.paymentStatus = QBPayStatusNotProcessed;
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    [self.commitModel commitPaymentInfo:paymentInfo];
}

- (void)usePaymentConfigInTestServer:(BOOL)useTestConfig {
    self.configModel.isTest = useTestConfig;
}

- (void)activatePaymentInfos:(NSArray<QBPaymentInfo *> *)paymentInfos
       withCompletionHandler:(QBCompletionHandler)completionHandler
{
    NSMutableString *orders = [NSMutableString string];
    [paymentInfos enumerateObjectsUsingBlock:^(QBPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.orderId.length > 0) {
            [orders appendString:obj.orderId];
            
            if (idx != paymentInfos.count-1) {
                [orders appendString:@"|"];
            }
        }
    }];
    
    if (orders.length == 0) {
        QBSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    @weakify(self);
    [self.orderQueryModel queryOrder:orders withCompletionHandler:^(BOOL success, id obj) {
        if (success) {
            if (![obj isKindOfClass:[NSString class]]) {
                QBSafelyCallBlock(completionHandler, NO, nil);
                return ;
            }
            
            NSArray<NSString *> *paidOrders = [obj componentsSeparatedByString:@"|"];
            __block QBPaymentInfo *paidPaymentInfo;
            [paymentInfos enumerateObjectsUsingBlock:^(QBPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([paidOrders containsObject:obj.orderId]) {
                    paidPaymentInfo = obj;
                    *stop = YES;
                }
            }];
            
            if (paidPaymentInfo) {
                @strongify(self);
                [self onPaymentResult:QBPayResultSuccess withPaymentInfo:paidPaymentInfo];
            }
            
            QBSafelyCallBlock(completionHandler, paidPaymentInfo != nil, paidPaymentInfo);
        } else {
            QBSafelyCallBlock(completionHandler, NO, nil);
        }
    }];
}

#ifdef QBPAYMENT_VIAPAY_ENABLED

#pragma mark - stringDelegate

- (void)getResult:(NSDictionary *)sender {
    QBPayResult paymentResult = sender[@"result"] == nil ? QBPayResultFailure : [sender[@"result"] integerValue] == 0 ? QBPayResultSuccess : QBPayResultFailure;
    if (paymentResult == QBPayResultFailure) {
        QBLog(@"首游时空支付失败：%@", sender[@"info"]);
//    } else if (paymentResult == PAYRESULT_SUCCESS) {
//        UIViewController *currentController = [QBUtil currentVisibleViewController];
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
#endif
@end
