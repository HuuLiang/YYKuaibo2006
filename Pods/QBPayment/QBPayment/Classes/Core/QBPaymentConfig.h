//
//  QBPaymentConfig.h
//  QBuaibo
//
//  Created by Sean Yue on 16/8/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "QBURLResponse.h"
#import "QBPaymentConfigSummary.h"
#import "QBPaymentConfigDetail.h"
#import "QBPaymentDefines.h"

@interface QBPaymentConfig : QBURLResponse

@property (nonatomic,retain) QBPaymentConfigSummary *payConfig;
@property (nonatomic,retain) QBPaymentConfigDetail *configDetails;

+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;

- (QBPayType)wechatPaymentType;
- (QBPayType)alipayPaymentType;
- (QBPayType)qqPaymentType;

@end