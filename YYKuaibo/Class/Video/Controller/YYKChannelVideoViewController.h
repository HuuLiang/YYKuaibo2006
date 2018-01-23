//
//  YYKChannelVideoViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoListViewController.h"

@interface YYKChannelVideoViewController : YYKVideoListViewController

@property (nonatomic,retain,readonly) YYKChannel *channel;

- (instancetype)init __attribute__((unavailable("Use -initWithChannel: instead")));
- (instancetype)initWithChannel:(YYKChannel *)channel;

@end
