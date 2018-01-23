//
//  YYKManualActivationManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKManualActivationManager : NSObject

+ (instancetype)sharedManager;

- (void)doActivation;


@end
