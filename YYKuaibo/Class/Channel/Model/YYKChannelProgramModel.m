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
    return [YYKPrograms class];
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
                        
                        YYKPrograms *programs;
                        if (respStatus == YYKURLResponseSuccess) {
                            programs = (YYKPrograms *)self.response;
                            self.fetchedPrograms = programs;
                        }
                        
                        if (handler) {
                            handler(respStatus==YYKURLResponseSuccess, programs);
                        }
                    }];
    return success;
}

@end