//
//  YYKKeyword.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKKeyword : NSObject

@property (nonatomic) NSString *text;
@property (nonatomic) BOOL isTag;

+ (NSArray<YYKKeyword *> *)allKeywords;
+ (void)deleteAllKeywords;

+ (instancetype)keywordWithText:(NSString *)text isTag:(BOOL)isTag;
- (void)markSearched;

@end
