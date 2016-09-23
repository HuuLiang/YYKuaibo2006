//
//  YYKSystemConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//
#import "YYKSystemConfig.h"

@class YYKProgram;
//支付弹框里面的图片以及商品的价格,及价格区间都在这里获取
@interface YYKSystemConfigResponse : YYKURLResponse
@property (nonatomic,retain) NSArray<YYKSystemConfig> *confis;
@end

typedef void (^YYKFetchSystemConfigCompletionHandler)(BOOL success);

@interface YYKSystemConfigModel : YYKEncryptedURLRequest

@property (nonatomic) NSUInteger payAmount;
@property (nonatomic) NSUInteger svipPayAmount;
@property (nonatomic) NSUInteger allVIPPayAmount;
@property (nonatomic) NSUInteger originalPayAmount;
@property (nonatomic) NSUInteger originalSVIPPayAmount;

@property (nonatomic) NSString *paymentImage;
@property (nonatomic) NSString *svipPaymentImage;
@property (nonatomic) NSString *discountImage;
@property (nonatomic) NSString *channelTopImage;
@property (nonatomic) NSString *spreadTopImage;
@property (nonatomic) NSString *spreadURL;

@property (nonatomic) NSString *startupInstall;
@property (nonatomic) NSString *startupPrompt;

@property (nonatomic) NSString *H5Region;
@property (nonatomic) NSString *imageToken;

//@property (nonatomic) NSString *contact;
@property (nonatomic) NSString *contactScheme;
@property (nonatomic) NSString *contactName;
@property (nonatomic) NSString *contactTime;

@property (nonatomic) CGFloat discountAmount;
@property (nonatomic) NSInteger discountLaunchSeq;
@property (nonatomic) NSInteger notificationLaunchSeq;
@property (nonatomic) NSInteger notificationBackgroundDelay;
@property (nonatomic) NSString *notificationText;
@property (nonatomic) NSString *notificationRepeatTimes;

//价格区间
@property (nonatomic) NSString *priceMin;
@property (nonatomic) NSString *priceMax;
@property (nonatomic) NSString *priceExclude;

//SVIP价格区间
@property (nonatomic) NSString *svipPriceMin;
@property (nonatomic) NSString *svipPriceMax;
@property (nonatomic) NSString *svipPriceExclude;

@property (nonatomic) NSString *allVIPPriceMin;
@property (nonatomic) NSString *allVIPPriceMax;
@property (nonatomic) NSString *allVIPPriceExclude;

@property (nonatomic) NSUInteger statsTimeInterval;

//@property (nonatomic) NSString *spreadLeftImage;
//@property (nonatomic) NSString *spreadLeftUrl;
//@property (nonatomic) NSString *spreadRightImage;
//@property (nonatomic) NSString *spreadRightUrl;

@property (nonatomic,readonly) BOOL loaded;
@property (nonatomic,readonly) BOOL hasDiscount;

+ (instancetype)sharedModel;

- (BOOL)fetchSystemConfigWithCompletionHandler:(YYKFetchSystemConfigCompletionHandler)handler;
- (NSUInteger)paymentPriceWithProgram:(YYKProgram *)program;
- (NSUInteger)paymentPriceWithPayPointType:(QBPayPointType)payPointType;
- (NSString *)paymentImageWithProgram:(YYKProgram *)program;
- (NSString *)paymentImageWithPayPointType:(QBPayPointType)payPointType;

@end
