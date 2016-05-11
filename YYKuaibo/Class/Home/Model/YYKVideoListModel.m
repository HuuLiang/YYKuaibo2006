//
//  YYKVideoListModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoListModel.h"

@implementation YYKVideoListModel

+ (Class)responseClass {
    return [YYKChannel class];
}

- (BOOL)fetchVideosInSpace:(YYKVideoListSpace)space
                      page:(NSUInteger)page
     withCompletionHandler:(YYKCompletionHandler)handler
{
    @weakify(self);
    BOOL ret = [self requestURLPath:space==YYKVideoListSpaceHot ? YYK_HOT_VIDEO_URL : YYK_VIP_VIDEO_URL
                     standbyURLPath:space==YYKVideoListSpaceHot ? YYK_STANDBY_HOT_VIDEO_URL : YYK_STANDBY_VIP_VIDEO_URL
                         withParams:@{@"page":@(page)}
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKChannel *videos;
        if (respStatus == YYKURLResponseSuccess) {
            videos = self.response;
            self->_fetchedVideoChannel = videos;
        }
        
        if (handler) {
            handler(respStatus == YYKURLResponseSuccess, videos);
        }
    }];
    return ret;
}

@end
