//
//  YYKHomeVideoModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

@interface YYKHomeProgramResponse : YYKURLResponse
@property (nonatomic,retain) NSArray<YYKChannel *> *columnList;
@end

@interface YYKHomeProgramModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<YYKChannel *> *fetchedProgramList;
@property (nonatomic,retain,readonly) NSArray<YYKChannel *> *fetchedVideoAndAdProgramList;

@property (nonatomic,retain,readonly) YYKChannel *fetchedBannerChannel;
@property (nonatomic,retain,readonly) YYKChannel *fetchedTrialChannel;

- (BOOL)fetchProgramsWithCompletionHandler:(YYKCompletionHandler)handler;

@end