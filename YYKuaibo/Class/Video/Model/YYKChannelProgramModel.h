//
//  YYKChannelProgramModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

@interface YYKChannelProgramModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKChannel *fetchedVideoChannel;

- (BOOL)fetchVideosInColumn:(NSNumber *)columnId page:(NSUInteger)page withCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
