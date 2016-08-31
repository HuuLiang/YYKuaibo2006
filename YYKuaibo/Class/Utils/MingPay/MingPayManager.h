//
//  MingPayManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/11.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MingPayManager : NSObject

@property (nonatomic) NSString *mch;
@property (nonatomic) NSString *payUrl;
@property (nonatomic) NSString *queryOrderUrl;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo completionHandler:(YYKPaymentCompletionHandler)completionHandler;
- (NSString *)processOrderNo:(NSString *)orderNo;

@end
