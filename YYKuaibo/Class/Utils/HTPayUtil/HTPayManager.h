//
//  HTPayManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/9/1.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTPayManager : NSObject

@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo
         completionHandler:(YYKPaymentCompletionHandler)completionHandler;
@end
