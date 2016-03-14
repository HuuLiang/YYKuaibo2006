//
//  YYKVideoLibModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoLibModel.h"

@implementation YYKVideoLibModel

+ (Class)responseClass {
    return [YYKVideos class];
}

- (BOOL)fetchVideosInPage:(NSUInteger)page withCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_VIDEO_LIB_URL
                         withParams:@{@"page":@(page)}
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKVideos *videos;
        if (respStatus == YYKURLResponseSuccess) {
            videos = self.response;
            self->_fetchedVideos = videos;
        }
        
        if (handler) {
            handler(respStatus == YYKURLResponseSuccess, videos);
        }
    }];
    return ret;
}

@end
