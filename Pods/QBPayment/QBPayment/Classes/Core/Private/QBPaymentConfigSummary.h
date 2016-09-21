//
//  QBPaymentConfigSummary.h
//  QBuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBURLResponse.h"

extern NSString *const kQBWeChatPayConfigName;
extern NSString *const kQBAlipayPayConfigName;
extern NSString *const kQBUnionPayConfigName;
extern NSString *const kQBQQPayConfigName;

@interface QBPaymentConfigSummary : NSObject <QBResponseParsable>

@property (nonatomic) NSString *wechat;
@property (nonatomic) NSString *alipay;
@property (nonatomic) NSString *unionpay;
@property (nonatomic) NSString *qqpay;

@end
