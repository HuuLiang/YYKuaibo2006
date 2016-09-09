//
//  DXTXPayManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/9/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXTXPayManager : NSObject

@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo
         completionHandler:(YYKPaymentCompletionHandler)completionHandler;

@end
