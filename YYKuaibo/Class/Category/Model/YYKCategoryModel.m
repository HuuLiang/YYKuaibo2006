//
//  YYKCategoryModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCategoryModel.h"

@implementation YYKCategoryModel

RequestTimeOutInterval

+ (Class)responseClass {
    return [YYKCategoryList class];
}

- (BOOL)fetchCategoryWithCompletionHandler:(QBCompletionHandler)completionHandler {
    return [self fetchCategoryInSpace:YYKCategorySpaceNormal withCompletionHandler:completionHandler];
}

- (BOOL)fetchCategoryInSpace:(YYKCategorySpace)space withCompletionHandler:(QBCompletionHandler)completionHandler {
    
    @weakify(self);
    BOOL ret = [self requestURLPath:space == YYKCategorySpaceRanking ? YYK_RANKING_URL : YYK_CATEGORY_URL
                     standbyURLPath:[YYKUtil getStandByUrlPathWithOriginalUrl:space == YYKCategorySpaceRanking ? YYK_RANKING_URL : YYK_CATEGORY_URL params:nil]
                         withParams:nil
                    responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage) {
                        @strongify(self);
                        if (!self) {
                            return ;
                        }
                        
                        NSArray *categories;
                        if (respStatus == QBURLResponseSuccess) {
                            YYKCategoryList *resp = self.response;
                            categories = resp.columnList;
                            self->_fetchedCategories = categories;
                        }
                        
                        SafelyCallBlock(completionHandler, respStatus == QBURLResponseSuccess, categories);
                    }];
    
    return ret;
}

@end
