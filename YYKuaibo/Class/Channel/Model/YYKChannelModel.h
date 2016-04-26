//
//  YYKChannelModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"
#import "YYKChannel.h"

@interface YYKChannelResponse : YYKURLResponse
@property (nonatomic,retain) NSMutableArray<YYKChannel *> *columnList;

@end

typedef void (^YYKFetchChannelsCompletionHandler)(BOOL success, NSArray<YYKChannel *> *channels);

@interface YYKChannelModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray *fetchedChannels;

- (BOOL)fetchChannelsWithCompletionHandler:(YYKFetchChannelsCompletionHandler)handler;

@end