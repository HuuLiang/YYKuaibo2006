//
//  YYKHomeVideoModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"
#import "YYKProgram.h"

@interface YYKHomeProgramResponse : YYKURLResponse
@property (nonatomic,retain) NSArray<YYKPrograms> *columnList;
@end

@interface YYKHomeProgramModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<YYKPrograms *> *fetchedProgramList;
@property (nonatomic,retain,readonly) NSArray<YYKPrograms *> *fetchedVideoAndAdProgramList;

@property (nonatomic,retain,readonly) NSArray<YYKProgram *> *fetchedBannerPrograms;
@property (nonatomic,retain,readonly) NSArray<YYKProgram *> *fetchedTrialVideos;

- (BOOL)fetchProgramsWithCompletionHandler:(YYKCompletionHandler)handler;

@end