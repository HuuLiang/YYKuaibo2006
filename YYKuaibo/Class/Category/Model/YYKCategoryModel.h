//
//  YYKCategoryModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

typedef NS_ENUM(NSUInteger, YYKCategorySpace) {
    YYKCategorySpaceNormal,
    YYKCategorySpaceRanking
};

@interface YYKCategoryModel : QBEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<YYKCategory *> *fetchedCategories;

- (BOOL)fetchCategoryWithCompletionHandler:(QBCompletionHandler)completionHandler;
- (BOOL)fetchCategoryInSpace:(YYKCategorySpace)space withCompletionHandler:(QBCompletionHandler)completionHandler;

@end
