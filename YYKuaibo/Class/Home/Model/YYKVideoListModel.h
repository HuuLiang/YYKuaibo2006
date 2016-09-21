//
//  YYKVideoListModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

typedef NS_ENUM(NSUInteger, YYKVideoListSpace) {
    YYKVideoListSpaceHot,
    YYKVideoListSpaceVIP
};

@class YYKChannel;
@interface YYKVideoListModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKChannel *fetchedVideoChannel;

- (BOOL)fetchVideosInSpace:(YYKVideoListSpace)space page:(NSUInteger)page withCompletionHandler:(YYKCompletionHandler)handler;
@end
