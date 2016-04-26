//
//  YYKChannelProgramModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"
#import "YYKProgram.h"

typedef void (^YYKFetchChannelProgramCompletionHandler)(BOOL success, YYKPrograms *programs);

@interface YYKChannelProgramModel : YYKEncryptedURLRequest

@property (nonatomic,retain) YYKPrograms *fetchedPrograms;

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(YYKFetchChannelProgramCompletionHandler)handler;

@end