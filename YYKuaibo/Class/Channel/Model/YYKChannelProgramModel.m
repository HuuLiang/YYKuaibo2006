//
//  YYKChannelProgramModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelProgramModel.h"

@implementation YYKChannelProgramModel

+ (Class)responseClass {
    return [YYKChannel class];
}

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(YYKFetchChannelProgramCompletionHandler)handler {
    if (columnId == nil) {
        if (handler) {
            handler(NO, nil);
        }
        return NO;
    }
    
    @weakify(self);
    NSDictionary *params = @{@"columnId":columnId, @"page":@(pageNo), @"pageSize":@(pageSize)};
    NSString *standbyURLPath = [NSString stringWithFormat:YYK_STANDBY_CHANNEL_PROGRAM_URL, columnId, @(pageNo)];
    BOOL success = [self requestURLPath:YYK_CHANNEL_PROGRAM_URL
                         standbyURLPath:standbyURLPath
                             withParams:params
                        responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        @strongify(self);
                        
                        YYKChannel *channel;
                        if (respStatus == YYKURLResponseSuccess) {
                            channel = (YYKChannel *)self.response;
                            self.fetchedChannel = channel;
                        }
                        SafelyCallBlock(handler,respStatus==YYKURLResponseSuccess,channel);
                    }];
    return success;
}

@end