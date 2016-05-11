//
//  YYKCPCStatsModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCPCStatsModel.h"

@implementation YYKCPCStatsModel

- (BOOL)statsCPCWithStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos
             completionHandler:(YYKCompletionHandler)completionHandler
{
    NSArray<NSDictionary *> *params = [self validateParamsWithStatsInfos:statsInfos];
    if (params.count == 0) {
        SafelyCallBlock(completionHandler, NO, nil);
        return NO;
    }

    BOOL ret = [self requestURLPath:YYK_STATS_CPC_URL
                         withParams:params
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
                {
                    SafelyCallBlock(completionHandler, respStatus==YYKURLResponseSuccess, errorMessage);
                }];
    return ret;
}

@end
