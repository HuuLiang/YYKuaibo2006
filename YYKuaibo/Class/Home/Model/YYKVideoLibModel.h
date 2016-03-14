//
//  YYKVideoLibModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"
#import "YYKVideos.h"

@interface YYKVideoLibModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKVideos *fetchedVideos;

- (BOOL)fetchVideosInPage:(NSUInteger)page withCompletionHandler:(YYKCompletionHandler)handler;

@end
