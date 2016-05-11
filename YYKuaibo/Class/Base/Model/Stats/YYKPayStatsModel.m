//
//  YYKPayStatsModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPayStatsModel.h"

@implementation YYKPayStatsModel

- (BOOL)statsPayWithStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos completionHandler:(YYKCompletionHandler)completionHandler {
    NSArray<NSDictionary *> *params = [self validateParamsWithStatsInfos:statsInfos shouldIncludeStatsType:NO];
    if (params.count == 0) {
        SafelyCallBlock(completionHandler,NO,nil);
        return NO;
    }
    
    BOOL ret = [self requestURLPath:YYK_STATS_PAY_URL
                         withParams:params
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        SafelyCallBlock(completionHandler, respStatus==YYKURLResponseSuccess, errorMessage);
    }];
    return ret;
}

@end
