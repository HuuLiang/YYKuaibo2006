//
//  YYKVideoPlayerViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@interface YYKVideoPlayerViewController : YYKBaseViewController

@property (nonatomic,retain,readonly) YYKProgram *video;
@property (nonatomic,copy) YYKAction playEndAction;
@property (nonatomic,copy) YYKAction closeAction;

- (instancetype)initWithVideo:(YYKProgram *)video;
- (void)pause;

@end
