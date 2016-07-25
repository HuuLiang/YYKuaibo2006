//
//  YYKPaymentManager.h
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYKProgram;
@class YYKChannel;

@interface YYKPaymentManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;
- (YYKPaymentInfo *)startPaymentWithType:(YYKPaymentType)type
                                 subType:(YYKPaymentType)subType
                                   price:(NSUInteger)price
                            payPointType:(YYKPayPointType)payPointType
                              forProgram:(YYKProgram *)program
                         programLocation:(NSUInteger)programLocation
                               inChannel:(YYKChannel *)channel
                       completionHandler:(YYKPaymentCompletionHandler)handler;

// Application delegate methods

- (void)applicationWillEnterForeground;
- (void)handleOpenUrl:(NSURL *)url;
- (YYKPaymentType)wechatPaymentType;
- (YYKPaymentType)alipayPaymentType;
- (YYKPaymentType)cardPayPaymentType;

//- (void)checkPayment;

@end
