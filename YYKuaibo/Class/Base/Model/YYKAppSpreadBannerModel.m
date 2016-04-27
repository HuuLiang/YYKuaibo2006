//
//  YYKAppSpreadBannerModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKAppSpreadBannerModel.h"

@implementation YYKAppSpreadBannerResponse

- (Class)programListElementClass {
    return [YYKProgram class];
}
@end

@implementation YYKAppSpreadBannerModel

+ (instancetype)sharedModel {
    static YYKAppSpreadBannerModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}
+ (Class)responseClass {
    return [YYKAppSpreadBannerResponse class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)fetchAppSpreadWithCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:YYK_APP_SPREAD_BANNER_URL
                     standbyURLPath:YYK_STANDBY_APP_SPREAD_BANNER_URL
                         withParams:nil
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
                {
                    @strongify(self);
                    NSArray *fetchedSpreads;
                    if (respStatus == YYKURLResponseSuccess) {
                        YYKAppSpreadBannerResponse *resp = self.response;
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
