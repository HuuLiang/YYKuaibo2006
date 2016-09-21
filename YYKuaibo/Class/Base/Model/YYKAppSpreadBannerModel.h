//
//  YYKAppSpreadBannerModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

@interface YYKAppSpreadBannerResponse : YYKURLResponse
@property (nonatomic,retain) NSArray<YYKProgram *> *programList;
@end

@interface YYKAppSpreadBannerModel : YYKEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<YYKProgram *> *fetchedSpreads;

+ (instancetype)sharedModel;

- (BOOL)fetchAppSpreadWithCompletionHandler:(YYKCompletionHandler)handler;

@end
