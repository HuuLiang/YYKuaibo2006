//
//  YYKPaymentConfigSummary.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kYYKWeChatPayConfigName;
extern NSString *const kYYKAlipayPayConfigName;
extern NSString *const kYYKUnionPayConfigName;
extern NSString *const kYYKQQPayConfigName;

@interface YYKPaymentConfigSummary : NSObject <YYKResponseParsable>

@property (nonatomic) NSString *wechat;
@property (nonatomic) NSString *alipay;
@property (nonatomic) NSString *unionpay;
@property (nonatomic) NSString *qqpay;

@end
