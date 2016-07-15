//
//  YYKSearchModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

@interface YYKSearchResults : YYKURLResponse

@property (nonatomic) NSString *word;
@property (nonatomic,retain) NSArray<YYKProgram *> *programList;

@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;

@end

typedef void (^YYKSearchCompletionHandler)(YYKSearchResults *results, NSError *error);

@interface YYKSearchModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKSearchResults *searchedResults;

- (BOOL)searchKeywords:(NSString *)keywords
          isTagKeyword:(BOOL)isTagKeyword
                inPage:(NSUInteger)page
 withCompletionHandler:(YYKSearchCompletionHandler)completionHandler;

@end