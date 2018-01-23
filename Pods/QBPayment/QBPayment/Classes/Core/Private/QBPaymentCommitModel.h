//
//  QBPaymentCommitModel.h
//  Pods
//
//  Created by Sean Yue on 16/9/20.
//
//

#import "QBPaymentURLRequest.h"

@class QBPaymentInfo;

@interface QBPaymentCommitModel : QBPaymentURLRequest

- (BOOL)commitPaymentInfo:(QBPaymentInfo *)paymentInfo;
- (void)startRetryingToCommitUnprocessedOrders;

@end
