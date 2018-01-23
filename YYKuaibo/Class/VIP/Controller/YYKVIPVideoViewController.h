//
//  YYKVIPVideoViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@interface YYKVIPVideoViewController : YYKBaseViewController

@property (nonatomic,retain,readonly) YYKChannel *channel;

- (instancetype)initWithChannel:(YYKChannel *)channel;

@end
