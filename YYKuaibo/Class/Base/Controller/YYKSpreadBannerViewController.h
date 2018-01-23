//
//  YYKSpreadBannerViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@class YYKProgram;

@interface YYKSpreadBannerViewController : YYKBaseViewController

@property (nonatomic,retain,readonly) NSArray<YYKProgram *> *spreads;

- (instancetype)initWithSpreads:(NSArray<YYKProgram *> *)spreads;
- (void)showInViewController:(UIViewController *)viewController;

@end
