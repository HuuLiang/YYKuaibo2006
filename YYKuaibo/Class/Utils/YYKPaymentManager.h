//
//  YYKPaymentManager.h
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYKProgram;

typedef void (^YYKPaymentCompletionHandler)(PAYRESULT payResult, YYKPaymentInfo *paymentInfo);

@interface YYKPaymentManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;
- (BOOL)startPaymentWithType:(YYKPaymentType)type
                     subType:(YYKPaymentType)subType
                       price:(NSUInteger)price
                  forProgram:(YYKProgram *)program
           completionHandler:(YYKPaymentCompletionHandler)handler;

- (void)handleOpenURL:(NSURL *)url;
//- (void)checkPayment;

@end
