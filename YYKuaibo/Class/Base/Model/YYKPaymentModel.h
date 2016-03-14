//
//  YYKPaymentModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"
#import "YYKPaymentInfo.h"

@interface YYKPaymentModel : YYKEncryptedURLRequest

+ (instancetype)sharedModel;

- (void)startRetryingToCommitUnprocessedOrders;
- (void)commitUnprocessedOrders;
- (BOOL)commitPaymentInfo:(YYKPaymentInfo *)paymentInfo;

@end
