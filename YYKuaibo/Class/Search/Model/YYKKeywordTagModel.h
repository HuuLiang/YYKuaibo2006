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
@property (nonatomic,retain) NSArray<YYKProgram *> *hotSearch;

@property (nonatomic) NSNumber *hsColumnId;
@property (nonatomic) NSNumber *hsRealColumnId;
@end

@interface YYKKeywordTagModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<NSString *> *fetchedTags;
//@property (nonatomic,retain,readonly) NSArray<YYKProgram *> *fetchedHotPrograms;
@property (nonatomic,retain,readonly) YYKChannel *fetchedHotChannel;

- (BOOL)fetchTagsWithCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
