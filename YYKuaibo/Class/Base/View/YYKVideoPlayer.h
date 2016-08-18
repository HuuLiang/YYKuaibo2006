//
//  YYKVideoPlayer.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYKVideoPlayer;

@protocol YYKVideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayerDidStartPlayVideo:(YYKVideoPlayer *)videoPlayer;
- (void)videoPlayerDidEndPlayVideo:(YYKVideoPlayer *)videoPlayer;
- (void)videoPlayer:(YYKVideoPlayer *)videoPlayer playingVideoInSeconds:(CGFloat)seconds withDuration:(CGFloat)duration;

@end

@interface YYKVideoPlayer : UIView

@property (nonatomic,readonly) NSURL *videoURL;
//@property (nonatomic,copy) YYKAction startPlayAction;
//@property (nonatomic,copy) YYKAction endPlayAction;
//@property (nonatomic,copy) YYKAction playProgressAction;
@property (nonatomic,readonly) CGFloat duration;
@property (nonatomic,weak) id<YYKVideoPlayerDelegate> delegate;

- (instancetype)initWithVideoURL:(NSURL *)videoURL delegate:(id<YYKVideoPlayerDelegate>)delegate;
- (void)startToPlay;
- (void)pause;

@end
