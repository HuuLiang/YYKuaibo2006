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
        
        NSArray *tags;
        if (respStatus == YYKURLResponseSuccess) {
            YYKKeywordTags *resp = self.response;
            tags = resp.tags;
            self->_fetchedTags = tags;
        }
        
        SafelyCallBlock(completionHandler, respStatus == YYKURLResponseSuccess, tags);
    }];
    return ret;
}
@end
