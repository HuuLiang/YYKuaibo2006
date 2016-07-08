//
//  YYKVersionUpdateModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/8.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

@interface YYKVersionUpdateInfo : YYKURLResponse

@property (nonatomic) NSString *versionNo;
@property (nonatomic) NSString *linkUrl;

@end

@interface YYKVersionUpdateModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKVersionUpdateInfo *fetchedVersionInfo;

- (BOOL)fetchLatestVersionWithCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
