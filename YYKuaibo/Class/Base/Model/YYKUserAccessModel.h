//
//  YYKUserAccessModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/26.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

typedef void (^YYKUserAccessCompletionHandler)(BOOL success);

@interface YYKUserAccessModel : YYKEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)requestUserAccess;

@end
