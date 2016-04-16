//
//  YYKSystemConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"
#import "YYKSystemConfig.h"

@interface YYKSystemConfigResponse : YYKURLResponse
@property (nonatomic,retain) NSArray<YYKSystemConfig> *confis;
@end

typedef void (^YYKFetchSystemConfigCompletionHandler)(BOOL success);

@interface YYKSystemConfigModel : YYKEncryptedURLRequest

@property (nonatomic) double payAmount;
@property (nonatomic) NSString *paymentImage;
@property (nonatomic) NSString *discountImage;
@property (nonatomic) NSString *channelTopImage;
@property (nonatomic) NSString *spreadTopImage;
@property (nonatomic) NSString *spreadURL;

@property (nonatomic) NSString *startupInstall;
@property (nonatomic) NSString *startupPrompt;

@property (nonatomic) NSString *contact;

@property (nonatomic) CGFloat discountAmount;
@property (nonatomic) NSInteger discountLaunchSeq;
@property (nonatomic) NSInteger notificationLaunchSeq;
@property (nonatomic) NSInteger notificationBackgroundDelay;
@property (nonatomic) NSString *notificationText;
@property (nonatomic) NSString *notificationRepeatTimes;

//@property (nonatomic) NSString *spreadLeftImage;
//@property (nonatomic) NSString *spreadLeftUrl;
//@property (nonatomic) NSString *spreadRightImage;
//@property (nonatomic) NSString *spreadRightUrl;

@property (nonatomic,readonly) BOOL loaded;
@property (nonatomic,readonly) BOOL hasDiscount;

+ (instancetype)sharedModel;

- (BOOL)fetchSystemConfigWithCompletionHandler:(YYKFetchSystemConfigCompletionHandler)handler;

@end
