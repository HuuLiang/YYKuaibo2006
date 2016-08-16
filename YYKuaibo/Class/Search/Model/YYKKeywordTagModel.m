//
//  YYKKeywordTagModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKKeywordTagModel.h"

@implementation YYKKeywordTags

- (Class)tagsElementClass {
    return [NSString class];
}

- (Class)hotSearchElementClass {
    return [YYKProgram class];
}

@end

@implementation YYKKeywordTagModel

+ (Class)responseClass {
    return [YYKKeywordTags class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)fetchTagsWithCompletionHandler:(YYKCompletionHandler)completionHandler {
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_HOT_TAG_URL
                         withParams:nil
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKKeywordTags *resp;
        if (respStatus == YYKURLResponseSuccess) {
            resp = self.response;
            self->_fetchedTags = resp.tags;
            
            YYKChannel *channel = [[YYKChannel alloc] init];
            channel.columnId = resp.hsColumnId;
            channel.realColumnId = resp.hsRealColumnId;
            channel.programList = resp.hotSearch;
            channel.type = @(YYKProgramTypeVideo);
            
            self->_fetchedHotChannel = channel;
        }
        
        SafelyCallBlock(completionHandler, respStatus == YYKURLResponseSuccess, resp);
    }];
    return ret;
}
@end
