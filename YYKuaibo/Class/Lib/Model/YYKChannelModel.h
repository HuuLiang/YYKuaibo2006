//
//  YYKChannelModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

typedef NS_ENUM(NSUInteger, YYKChannelSpace) {
    YYKChannelSpaceDefault,
    YYKChannelSpaceSVIP
};

@interface YYKChannelModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray *fetchedChannels;

- (BOOL)fetchChannelsInSpace:(YYKChannelSpace)space withCompletionHandler:(YYKCompletionHandler)handler;

@end
