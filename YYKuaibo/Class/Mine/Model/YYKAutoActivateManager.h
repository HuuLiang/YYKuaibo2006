//
//  YYKAutoActivateManager.h
//  YYKuaibo
//
//  Created by Liang on 2016/11/2.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface YYKAutoActivateManager : NSObject
+ (instancetype)sharedManager;

- (void)requestExchangeCode:(NSString *)code;

@end
