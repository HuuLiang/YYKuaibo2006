//
//  YYKAppSpreadModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKAppSpreadModel.h"

@implementation YYKAppSpreadModel

+ (Class)responseClass {
    return [YYKChannel class];
}

- (BOOL)fetchAppSpreadWithCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_APP_SPREAD_LIST_URL
                     standbyURLPath:YYK_STANDBY_APP_SPREAD_LIST_URL
                         withParams:nil
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        YYKChannel *fetchedSpreadChannel;
        if (respStatus == YYKURLResponseSuccess) {
            fetchedSpreadChannel = self.response;
            _fetchedSpreadChannel = fetchedSpreadChannel;
        }
        
        if (handler) {
            handler(respStatus==YYKURLResponseSuccess, fetchedSpreadChannel);
        }
    }];
    return ret;
}

@end
