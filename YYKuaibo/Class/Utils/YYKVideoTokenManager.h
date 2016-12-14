//
//  YYKVideoTokenManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/23.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YYKVideoTokenCompletionHandler)(BOOL success, NSString *token, NSString *userId);

@interface YYKVideoTokenManager : NSObject

+ (instancetype)sharedManager;

- (void)requestTokenWithCompletionHandler:(YYKVideoTokenCompletionHandler)completionHandler;
- (NSString *)videoLinkWithOriginalLink:(NSString *)originalLink;
- (void)setValue:(NSString *)value forVideoHttpHeader:(NSString *)field;
@end
