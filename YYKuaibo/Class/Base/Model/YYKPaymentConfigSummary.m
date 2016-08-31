//
//  YYKPaymentConfigSummary.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPaymentConfigSummary.h"

NSString *const kYYKWeChatPayConfigName = @"WEIXIN";
NSString *const kYYKAlipayPayConfigName = @"ALIPAY";
NSString *const kYYKUnionPayConfigName = @"UNIONPAY";
NSString *const kYYKQQPayConfigName = @"QQPAY";

@implementation YYKPaymentConfigSummary

- (NSString *)YYK_propertyOfParsing:(NSString *)parsingName {
    NSDictionary *mapping = @{kYYKWeChatPayConfigName:NSStringFromSelector(@selector(wechat)),
                              kYYKAlipayPayConfigName:NSStringFromSelector(@selector(alipay)),
                              kYYKUnionPayConfigName:NSStringFromSelector(@selector(unionpay)),
                              kYYKQQPayConfigName:NSStringFromSelector(@selector(qqpay))};
    return mapping[parsingName];
}

@end
