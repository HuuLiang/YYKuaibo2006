//
//  YYKCPCStatsModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKStatsBaseModel.h"

@interface YYKCPCStatsModel : YYKStatsBaseModel

- (BOOL)statsCPCWithStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos
             completionHandler:(YYKCompletionHandler)completionHandler;

@end
