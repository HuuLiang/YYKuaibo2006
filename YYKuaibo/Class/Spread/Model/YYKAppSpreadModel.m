//
//  YYKAppSpreadModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKAppSpreadModel.h"

@implementation YYKAppSpreadResponse

- (Class)programListElementClass {
    return [YYKProgram class];
}
@end

@implementation YYKAppSpreadModel

+ (Class)responseClass {
    return [YYKAppSpreadResponse class];
}

- (BOOL)fetchAppSpreadWithCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_APP_SPREAD_LIST_URL
                     standbyURLPath:YYK_STANDBY_APP_SPREAD_LIST_URL
                         withParams:nil
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        NSArray *fetchedSpreads;
        if (respStatus == YYKURLResponseSuccess) {
            YYKAppSpreadResponse *resp = self.response;
            _fetchedSpreads = resp.programList;
            fetchedSpreads = _fetchedSpreads;
        }
        
        if (handler) {
            handler(respStatus==YYKURLResponseSuccess, fetchedSpreads);
        }
    }];
    return ret;
}

@end
