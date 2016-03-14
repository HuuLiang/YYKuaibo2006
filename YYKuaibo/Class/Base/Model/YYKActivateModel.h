//
//  YYKActivateModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"

typedef void (^YYKActivateHandler)(BOOL success, NSString *userId);

@interface YYKActivateModel : YYKEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)activateWithCompletionHandler:(YYKActivateHandler)handler;

@end
