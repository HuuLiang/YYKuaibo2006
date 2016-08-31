//
//  YYKPaymentConfig.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKURLResponse.h"
#import "YYKPaymentConfigSummary.h"
#import "YYKPaymentConfigDetail.h"

@interface YYKPaymentConfig : YYKURLResponse

@property (nonatomic,retain) YYKPaymentConfigSummary *payConfig;
@property (nonatomic,retain) YYKPaymentConfigDetail *configDetails;

+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;

- (YYKPaymentType)wechatPaymentType;
- (YYKPaymentType)alipayPaymentType;
- (YYKPaymentType)qqPaymentType;

@end