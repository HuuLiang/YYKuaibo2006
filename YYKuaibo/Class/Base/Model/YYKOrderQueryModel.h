//
//  YYKOrderQueryModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/20.
//  Copyright © 2016年 iqu8. All rights reserved.
//

@interface YYKOrderQueryModel : YYKEncryptedURLRequest

- (BOOL)queryOrder:(NSString *)orderId withCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
