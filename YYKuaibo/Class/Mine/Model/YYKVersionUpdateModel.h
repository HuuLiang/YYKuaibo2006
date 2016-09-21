//
//  YYKVersionUpdateModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/8.
//  Copyright © 2016年 iqu8. All rights reserved.
//

@interface YYKVersionUpdateInfo : YYKURLResponse

@property (nonatomic) NSString *versionNo;
@property (nonatomic) NSString *linkUrl;
@property (nonatomic) NSNumber *isForceToUpdate;

@end

@interface YYKVersionUpdateModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) YYKVersionUpdateInfo *fetchedVersionInfo;

+ (instancetype)sharedModel;
- (BOOL)fetchLatestVersionWithCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
