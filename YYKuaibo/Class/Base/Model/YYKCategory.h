//
//  YYKCategory.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YYKCategoryShowMode) {
    YYKCategoryShowModePlainText = 3,
    YYKCategoryShowModeRectText,
    YYKCategoryShowModeRoundImage,
    YYKCategoryShowModeRectImage,
    YYKCategoryShowModeIcon
};

@interface YYKCategory : YYKChannel

@property (nonatomic,retain) NSArray<YYKChannel *> *columnList;

@end

@interface YYKCategoryList : QBURLResponse

@property (nonatomic,retain) NSArray<YYKCategory *> *columnList;

@end


