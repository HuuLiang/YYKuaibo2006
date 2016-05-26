//
//  YYKChannelProgramModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

typedef void (^YYKFetchChannelProgramCompletionHandler)(BOOL success, YYKChannel *channel);

@interface YYKChannelProgramModel : YYKEncryptedURLRequest

@property (nonatomic,retain) YYKChannel *fetchedChannel;
@property (nonatomic,retain,readonly) NSArray<YYKChannel *> *cachedChannels;

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(YYKFetchChannelProgramCompletionHandler)handler;

@end