//
//  YYKVideoPlayer.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKVideoPlayer : UIView

@property (nonatomic) NSURL *videoURL;

- (instancetype)initWithVideoURL:(NSURL *)videoURL;
- (void)startToPlay;
- (void)pause;

@end
