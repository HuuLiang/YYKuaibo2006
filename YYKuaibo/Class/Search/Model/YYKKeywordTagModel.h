//
//  YYKKeywordTagModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

@interface YYKKeywordTags : YYKURLResponse
@property (nonatomic,retain) NSArray<NSString *> *tags;
@end

@interface YYKKeywordTagModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<NSString *> *fetchedTags;

- (BOOL)fetchTagsWithCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
