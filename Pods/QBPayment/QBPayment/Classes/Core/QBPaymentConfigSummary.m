//
//  QBPaymentConfigSummary.m
//  QBuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "QBPaymentConfigSummary.h"

NSString *const kQBWeChatPayConfigName = @"WEIXIN";
NSString *const kQBAlipayPayConfigName = @"ALIPAY";
NSString *const kQBUnionPayConfigName = @"UNIONPAY";
NSString *const kQBQQPayConfigName = @"QQPAY";

@implementation QBPaymentConfigSummary

- (NSString *)QB_propertyOfParsing:(NSString *)parsingName {
    NSDictionary *mapping = @{kQBWeChatPayConfigName:NSStringFromSelector(@selector(wechat)),
                              kQBAlipayPayConfigName:NSStringFromSelector(@selector(alipay)),
                              kQBUnionPayConfigName:NSStringFromSelector(@selector(unionpay)),
                              kQBQQPayConfigName:NSStringFromSelector(@selector(qqpay))};
    return mapping[parsingName];
}

@end
