//
//  IappPayMananger.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo completionHandler:(YYKPaymentCompletionHandler)completionHandler;

@end
