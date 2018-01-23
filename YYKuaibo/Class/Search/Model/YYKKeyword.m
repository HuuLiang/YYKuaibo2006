//
//  YYKKeyword.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKKeyword.h"

static NSString *const kSearchedKeywordsKeyName = @"yykuaibov_searchedkeywords_keyname";

@implementation YYKKeyword

+ (instancetype)keywordWithText:(NSString *)text isTag:(BOOL)isTag {
    YYKKeyword *keyword = [[self alloc] init];
    keyword.text = text;
    keyword.isTag = isTag;
    return keyword;
}

+ (void)saveKeywords:(NSArray<YYKKeyword *> *)keywords {
    NSMutableArray *dics = [NSMutableArray array];
    [keywords enumerateObjectsUsingBlock:^(YYKKeyword * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = [obj dictionaryRepresentationWithEncryptBlock:nil];
        if (dic) {
            [dics addObject:dic];
        }
    }];
    
    if (dics.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:dics forKey:kSearchedKeywordsKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)markSearched {
    NSArray<YYKKeyword *> *allKeywords = [[self class] allKeywords];
    NSMutableArray<YYKKeyword *> *allKeywordsM = allKeywords.mutableCopy;
    if (!allKeywordsM) {
        allKeywordsM = [NSMutableArray array];
    }
    
    YYKKeyword *sameKeyword = [allKeywordsM bk_match:^BOOL(YYKKeyword *obj) {
        return [obj.text isEqualToString:self.text];
    }];
    
    if (sameKeyword) {
        [allKeywordsM removeObject:sameKeyword];
    }
    
    [allKeywordsM insertObject:self atIndex:0];
    [[self class] saveKeywords:allKeywordsM];
}

+ (NSArray<YYKKeyword *> *)allKeywords {
    NSArray *keywordsDics = [[NSUserDefaults standardUserDefaults] objectForKey:kSearchedKeywordsKeyName];
    NSMutableArray *allKeywords = [NSMutableArray array];
    [keywordsDics enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YYKKeyword *keyword = [YYKKeyword objectFromDictionary:obj withDecryptBlock:nil];
        if (keyword) {
            [allKeywords addObject:keyword];
        }
    }];
    return allKeywords.count > 0 ? allKeywords : nil;
}

+ (void)deleteAllKeywords {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSearchedKeywordsKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
