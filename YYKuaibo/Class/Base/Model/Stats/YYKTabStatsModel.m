//
//  YYKTabStatsModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKTabStatsModel.h"

@implementation YYKTabStatsModel

- (BOOL)statsTabWithStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos
             completionHandler:(YYKCompletionHandler)completionHandler
{
    NSArray<NSDictionary *> *params = [self validateParamsWithStatsInfos:statsInfos];
    if (params.count == 0) {
        SafelyCallBlock(completionHandler,NO,nil);
        return NO;
    }
    
    BOOL ret = [self requestURLPath:YYK_STATS_TAB_URL
                         withParams:params
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        SafelyCallBlock(completionHandler, respStatus == YYKURLResponseSuccess, errorMessage);
    }];
    return ret;
}

@end
