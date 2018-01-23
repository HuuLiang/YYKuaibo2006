//
//  QBPaymentCommitModel.m
//  Pods
//
//  Created by Sean Yue on 16/9/20.
//
//

#import "QBPaymentCommitModel.h"
#import "QBDefines.h"
#import "RACEXTScope.h"
#import "QBPaymentInfo.h"
#import "QBPaymentNetworkingConfiguration.h"

static NSString *const kPaymentCommitURL = @"http://pay.jlswz.com/paycenter/qubaPr.json";
static const NSTimeInterval kRetryingTimeInterval = 180;

@interface QBPaymentCommitModel ()
@property (nonatomic,retain) NSTimer *retryingTimer;
@end

@implementation QBPaymentCommitModel

- (BOOL)commitPaymentInfo:(QBPaymentInfo *)paymentInfo {
    NSDictionary *statusDic = @{@(QBPayResultSuccess):@(1), @(QBPayResultFailure):@(0), @(QBPayResultCancelled):@(2), @(QBPayResultUnknown):@(0)};
    NSDictionary *paymentSubTypeDic = @{@(QBPaySubTypeWeChat):@"WEIXIN",
                                        @(QBPaySubTypeAlipay):@"ALIPAY",
                                        @(QBPaySubTypeUPPay):@"UNIONPAY",
                                        @(QBPaySubTypeQQ):@"QQPAY"};
    
    if (nil == paymentInfo.userId || paymentInfo.orderId.length == 0) {
        return NO;
    }
    
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSDictionary *params = @{@"uuid":paymentInfo.userId,
                             @"orderNo":paymentInfo.orderId,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":@(paymentInfo.orderPrice).stringValue,
                             @"channelNo":[QBPaymentNetworkingConfiguration defaultConfiguration].channelNo,
                             @"contentId":paymentInfo.contentId.stringValue ?: @"0",
                             @"contentType":paymentInfo.contentType.stringValue ?: @"0",
                             @"pluginType":@(paymentInfo.paymentType),
                             @"payType":paymentSubTypeDic[@(paymentInfo.paymentSubType)] ?: @"",
                             @"payPointType":@(paymentInfo.payPointType),
                             @"appId":[QBPaymentNetworkingConfiguration defaultConfiguration].RESTAppId,
                             @"versionNo":@(appVersion.integerValue),
                             @"status":statusDic[@(paymentInfo.paymentResult)],
                             @"pV":[QBPaymentNetworkingConfiguration defaultConfiguration].RESTpV,
                             @"payTime":paymentInfo.paymentTime};
    
    BOOL success = [super requestURLPath:kPaymentCommitURL
                              withParams:params
                         responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
                    {
                    if (respStatus == QBURLResponseSuccess) {
                        paymentInfo.paymentStatus = QBPayStatusProcessed;
                        [paymentInfo save];
                    } else {
                        QBLog(@"Payment: fails to commit the order with orderId:%@", paymentInfo.orderId);
                    }
                    }];
    return success;
}

- (void)startRetryingToCommitUnprocessedOrders {
    if (!self.retryingTimer) {
        @weakify(self);
        self.retryingTimer = [NSTimer scheduledTimerWithTimeInterval:kRetryingTimeInterval target:self selector:@selector(onTimerToCommitUnprocessedOrders:) userInfo:nil repeats:YES];
        [self.retryingTimer fire];
    }
}

- (void)onTimerToCommitUnprocessedOrders:(NSTimer *)timer {
    if (!self) {
        [timer invalidate];
        return ;
    }
    
    QBLog(@"Payment: on retrying to commit unprocessed orders!");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[QBPaymentInfo allPaymentInfos] enumerateObjectsUsingBlock:^(QBPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.paymentStatus == QBPayStatusNotProcessed) {
                [self commitPaymentInfo:obj];
            }
        }];
    });
}

- (void)stopRetryingToCommitUnprocessedOrders {
    [self.retryingTimer invalidate];
    self.retryingTimer = nil;
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(QBURLResponseHandler)responseHandler {
    NSDictionary *decryptedResponse = [self decryptResponse:responseObject];
    QBLog(@"Payment response : %@", decryptedResponse);
    NSNumber *respCode = decryptedResponse[@"response_code"];
    QBURLResponseStatus status = (respCode.unsignedIntegerValue == 100) ? QBURLResponseSuccess : QBURLResponseFailedByInterface;
    
    QBSafelyCallBlock(responseHandler, status, nil);
}

@end
