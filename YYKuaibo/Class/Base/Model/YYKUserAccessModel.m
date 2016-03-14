//
//  YYKUserAccessModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/26.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "YYKUserAccessModel.h"

@implementation YYKUserAccessModel

+ (Class)responseClass {
    return [NSString class];
}

+ (instancetype)sharedModel {
    static YYKUserAccessModel *_theInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _theInstance = [[YYKUserAccessModel alloc] init];
    });
    return _theInstance;
}

- (BOOL)requestUserAccess {
    NSString *userId = [YYKUtil userId];
    if (!userId) {
        return NO;
    }
    
    @weakify(self);
    BOOL ret = [super requestURLPath:YYK_USER_ACCESS_URL
                          withParams:@{@"userId":userId,@"accessId":[YYKUtil accessId]}
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        BOOL success = NO;
        if (respStatus == YYKURLResponseSuccess) {
            NSString *resp = self.response;
            success = [resp isEqualToString:@"SUCCESS"];
            if (success) {
                DLog(@"Record user access!");
            }
        }
    }];
    return ret;
}

@end
