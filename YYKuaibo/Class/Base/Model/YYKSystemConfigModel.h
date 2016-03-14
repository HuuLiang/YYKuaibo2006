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
@property (nonatomic) NSString *channelTopImage;
@property (nonatomic) NSString *spreadTopImage;
@property (nonatomic) NSString *spreadURL;

@property (nonatomic) NSString *startupInstall;
@property (nonatomic) NSString *startupPrompt;

@property (nonatomic) NSString *spreadLeftImage;
@property (nonatomic) NSString *spreadLeftUrl;
@property (nonatomic) NSString *spreadRightImage;
@property (nonatomic) NSString *spreadRightUrl;

@property (nonatomic,readonly) BOOL loaded;

+ (instancetype)sharedModel;

- (BOOL)fetchSystemConfigWithCompletionHandler:(YYKFetchSystemConfigCompletionHandler)handler;

@end
