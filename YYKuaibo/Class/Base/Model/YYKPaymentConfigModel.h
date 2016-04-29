//
//  YYKPaymentConfigModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKEncryptedURLRequest.h"
#import "YYKPaymentConfig.h"

@interface YYKPaymentConfigModel : YYKEncryptedURLRequest

@property (nonatomic,readonly) BOOL loaded;

+ (instancetype)sharedModel;

//- (BOOL)fetchConfigWithCompletionHandler:(YYKCompletionHandler)handler;

@end
