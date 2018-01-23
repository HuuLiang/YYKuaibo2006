//
//  YYKVideoDetailViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@interface YYKVideoDetailViewController : YYKBaseViewController

@property (nonatomic,retain,readonly) YYKChannel *channel;
@property (nonatomic,retain,readonly) YYKProgram *video;
@property (nonatomic,readonly) NSUInteger videoLocation;
@property (nonatomic) UIColor *tagBackgroundColor;

- (instancetype)init __attribute__((unavailable("Use -initWithVideo:videoLocation:inChannel: instead")));
- (instancetype)initWithVideo:(YYKProgram *)video videoLocation:(NSUInteger)videoLocation inChannel:(YYKChannel *)channel;
@end
