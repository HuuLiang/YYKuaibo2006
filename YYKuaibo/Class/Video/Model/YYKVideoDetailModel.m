//
//  YYKVideoDetailModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoDetailModel.h"

@implementation YYKVideoDetail

- (Class)hotProgramListElementClass {
    return [YYKProgram class];
}

- (Class)programClass {
    return [YYKProgram class];
}

- (Class)spreadAppClass {
    return [YYKProgram class];
}
@end

@implementation YYKVideoDetailModel

+ (Class)responseClass {
    return [YYKVideoDetail class];
}

- (BOOL)fetchDetailOfVideo:(YYKProgram *)video
                 inChannel:(YYKChannel *)channel
     withCompletionHandler:(YYKCompletionHandler)completionHandler {
    if (!video.programId || !channel.columnId) {
        SafelyCallBlock(completionHandler, NO, nil);
        return NO;
    }
    
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_VIDEO_DETAIL_URL
                         withParams:@{@"columnId":channel.columnId,
                                      @"programId":video.programId}
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKVideoDetail *detail;
        if (respStatus == YYKURLResponseSuccess) {
            detail = self.response;
            self->_fetchedDetail = detail;
        }
        
        SafelyCallBlock(completionHandler, respStatus==YYKURLResponseSuccess, detail);
    }];
    return ret;
}
@end
