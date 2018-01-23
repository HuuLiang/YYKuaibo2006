//
//  YYKPayStatsModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKStatsBaseModel.h"

@interface YYKPayStatsModel : YYKStatsBaseModel

- (BOOL)statsPayWithStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos completionHandler:(YYKCompletionHandler)completionHandler;

@end
