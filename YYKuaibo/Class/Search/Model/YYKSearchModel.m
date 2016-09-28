//
//  YYKSearchModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSearchModel.h"

NSString *const kSearchErrorDomain = @"com.yykuaibo.errordomain.search";
const NSInteger kSearchParameterErrorCode = -1;
const NSInteger kSearchLogicErrorCode = -2;
const NSInteger kSearchNetworkErrorCode = -3;
const NSInteger kSearchUnknownErrorCode = -999;
NSString *const kSearchErrorMessageKey = @"errorMessage";

@implementation YYKSearchResults

- (Class)programListElementClass {
    return [YYKProgram class];
}

@end

@implementation YYKSearchModel

+ (Class)responseClass {
    return [YYKSearchResults class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)searchKeywords:(NSString *)keywords
          isTagKeyword:(BOOL)isTagKeyword
                inPage:(NSUInteger)page
 withCompletionHandler:(YYKSearchCompletionHandler)completionHandler
{
    if (keywords.length == 0) {
        NSError *error = [NSError errorWithDomain:kSearchErrorDomain code:kSearchParameterErrorCode userInfo:@{kSearchErrorMessageKey:@"错误的参数"}];
        SafelyCallBlock(completionHandler, nil, error);
        return NO;
    }
    
    @weakify(self);
    NSDictionary *params = @{@"word":keywords, @"searchTag":isTagKeyword?@1:@2, @"page":@(page)};
    BOOL ret = [self requestURLPath:YYK_SEARCH_URL
                         withParams:params
                    responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKSearchResults *results;
        NSError *error;
        if (respStatus == QBURLResponseSuccess) {
            results = self.response;
            self->_searchedResults = results;
        } else if (respStatus == QBURLResponseFailedByInterface) {
            error = [NSError errorWithDomain:kSearchErrorDomain code:kSearchLogicErrorCode userInfo:@{kSearchErrorMessageKey:@"由于业务逻辑问题，您搜索的内容无法显示！"}];
        } else if (respStatus == QBURLResponseFailedByNetwork) {
            error = [NSError errorWithDomain:kSearchErrorDomain code:kSearchNetworkErrorCode userInfo:@{kSearchErrorMessageKey:@"由于网络问题，您搜索的内容无法显示！"}];
        } else {
            error = [NSError errorWithDomain:kSearchErrorMessageKey code:kSearchUnknownErrorCode userInfo:@{kSearchErrorMessageKey:@"搜索的过程中出现了未知的错误！"}];
        }
        
        SafelyCallBlock(completionHandler, results, error);
    }];
    return ret;
}

@end
