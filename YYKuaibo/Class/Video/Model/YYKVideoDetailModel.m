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

- (Class)spreadAppListElementClass {
    return [YYKProgram class];
}
//- (Class)spreadAppClass {
//    return [YYKProgram class];
//}
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
                    responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKVideoDetail *detail;
        if (respStatus == QBURLResponseSuccess) {
            detail = self.response;
            
            [YYKUtil requestAllInstalledAppIdsWithCompletionHandler:^(NSArray<NSString *> *appIds) {
                
                YYKProgram *firstUninstalledAppId = [detail.spreadAppList bk_match:^BOOL(YYKProgram *spread) {
                    return ![appIds containsObject:spread.specialDesc];
                }];
                detail.spreadApp = firstUninstalledAppId;
                self->_fetchedDetail = detail;
                SafelyCallBlock(completionHandler, YES, detail);
            }];
        } else {
            SafelyCallBlock(completionHandler, NO, errorMessage);
        }
    }];
    return ret;
}
@end
