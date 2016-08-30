//
//  YYKWebPlayerViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@interface YYKWebPlayerViewController : YYKBaseViewController

@property (nonatomic,retain,readonly) YYKProgram *program;

- (instancetype)initWithProgram:(YYKProgram *)program;

@end
