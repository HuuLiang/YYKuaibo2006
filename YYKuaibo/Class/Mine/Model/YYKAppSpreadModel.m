//
//  YYKAppSpreadModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKAppSpreadModel.h"

@implementation YYKAppSpreadModel
RequestTimeOutInterval

+ (Class)responseClass {
    return [YYKChannel class];
}

- (BOOL)fetchAppSpreadWithCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_APP_SPREAD_LIST_URL
                     standbyURLPath:[YYKUtil getStandByUrlPathWithOriginalUrl:YYK_APP_SPREAD_LIST_URL params:nil]
                         withParams:nil
                    responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        YYKChannel *fetchedSpreadChannel;
        if (respStatus == QBURLResponseSuccess) {
            fetchedSpreadChannel = self.response;
            _fetchedSpreadChannel = fetchedSpreadChannel;
        }
        
        if (handler) {
            handler(respStatus==QBURLResponseSuccess, fetchedSpreadChannel);
        }
    }];
    return ret;
}

@end
