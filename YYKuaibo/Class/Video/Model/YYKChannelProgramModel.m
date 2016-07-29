//
//  YYKChannelProgramModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelProgramModel.h"

@implementation YYKChannelProgramModel

+ (Class)responseClass {
    return [YYKChannel class];
}

- (BOOL)fetchVideosInColumn:(NSNumber *)columnId page:(NSUInteger)page withCompletionHandler:(YYKCompletionHandler)completionHandler {
    if (columnId == nil) {
        SafelyCallBlock(completionHandler, NO, nil);
        return NO;
    }
    
    @weakify(self);
    NSDictionary *params = @{@"columnId":columnId,
                             @"page":@(page),
                             @"pageSize":@(10)};
    BOOL ret = [self requestURLPath:YYK_CHANNEL_PROGRAM_URL withParams:params responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKChannel *channel;
        if (respStatus == YYKURLResponseSuccess) {
            channel = self.response;
            self->_fetchedVideoChannel = channel;
        }
        
        SafelyCallBlock(completionHandler, respStatus==YYKURLResponseSuccess, channel);
    }];
    return ret;
}
@end
