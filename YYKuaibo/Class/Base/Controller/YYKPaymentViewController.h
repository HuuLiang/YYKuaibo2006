//
//  YYKPaymentViewController.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "YYKBaseViewController.h"

@class YYKProgram;
@class YYKPaymentInfo;

@interface YYKPaymentViewController : YYKBaseViewController

+ (instancetype)sharedPaymentVC;

- (void)popupPaymentInView:(UIView *)view
                forProgram:(YYKProgram *)program
           programLocation:(NSUInteger)programLocation
                 inChannel:(YYKChannel *)channel
     withCompletionHandler:(void (^)(void))completionHandler
              footerAction:(YYKAction)footerAction;
- (void)hidePayment;

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(YYKPaymentInfo *)paymentInfo;

@end
