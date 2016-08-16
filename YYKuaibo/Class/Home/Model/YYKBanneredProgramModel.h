//
//  YYKBanneredProgramModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

typedef NS_ENUM(NSUInteger, YYKBanneredProgramSpace) {
    YYKBanneredProgramSpaceHome,
    YYKBanneredProgramSpaceVIP
};

@interface YYKBanneredProgramResponse : YYKURLResponse
@property (nonatomic,retain) NSArray<YYKChannel *> *columnList;
@end

@interface YYKBanneredProgramModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<YYKChannel *> *fetchedProgramList;
@property (nonatomic,retain,readonly) NSArray<YYKChannel *> *fetchedVideoProgramList;

@property (nonatomic,retain,readonly) YYKChannel *fetchedBannerChannel;
@property (nonatomic,retain,readonly) YYKChannel *fetchedRankingChannel;
@property (nonatomic,retain,readonly) YYKChannel *fetchedTrialChannel;

- (BOOL)fetchProgramsInSpace:(YYKBanneredProgramSpace)space withCompletionHandler:(YYKCompletionHandler)handler;

@end
