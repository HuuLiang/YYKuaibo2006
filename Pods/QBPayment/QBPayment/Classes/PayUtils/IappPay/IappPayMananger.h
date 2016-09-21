//
//  IappPayMananger.h
//  QBPayment
//
//  Created by Sean Yue on 16/6/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@class QBPaymentInfo;

@interface IappPayMananger : NSObject

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *waresid;
@property (nonatomic) NSString *appUserId;
@property (nonatomic) NSString *privateInfo;
@property (nonatomic) NSString *alipayURLScheme;

+ (instancetype)sharedMananger;
- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo payType:(QBPaySubType)payType completionHandler:(QBPaymentCompletionHandler)completionHandler;
- (void)handleOpenURL:(NSURL *)url;

@end
