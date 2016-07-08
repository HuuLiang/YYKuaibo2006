//
//  YYKVersionUpdateModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/8.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVersionUpdateModel.h"

@implementation YYKVersionUpdateInfo

@end

@implementation YYKVersionUpdateModel

- (BOOL)shouldPostErrorNotification {
    return NO;
}

+ (Class)responseClass {
    return [YYKVersionUpdateInfo class];
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)fetchLatestVersionWithCompletionHandler:(YYKCompletionHandler)completionHandler {
    @weakify(self);
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    BOOL ret = [self requestURLPath:YYK_VERSION_UPDATE_URL
                         withParams:@{@"versionNo":currentVersion, @"packageId":bundleId}
                    responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        YYKVersionUpdateInfo *versionInfo;
        if (respStatus == YYKURLResponseSuccess) {
            versionInfo = self.response;
            self->_fetchedVersionInfo = versionInfo;
        }
        
        SafelyCallBlock(completionHandler, respStatus==YYKURLResponseSuccess, versionInfo);
    }];
    return ret;
}
@end
