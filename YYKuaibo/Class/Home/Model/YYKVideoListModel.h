//
//  YYKVideoListModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

typedef NS_ENUM(NSUInteger, YYKVideoListSpace) {
    YYKVideoListSpaceLib,
    YYKVideoListSpaceHot
};

@class YYKVideos;

@interface YYKVideoListModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKVideos *fetchedVideos;

- (BOOL)fetchVideosInSpace:(YYKVideoListSpace)space page:(NSUInteger)page withCompletionHandler:(YYKCompletionHandler)handler;
@end
