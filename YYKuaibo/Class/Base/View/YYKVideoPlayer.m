//
//  YYKVideoPlayer.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoPlayer.h"

@import AVFoundation;

@interface YYKVideoPlayer ()
{
    UILabel *_loadingLabel;
}
@property (nonatomic,retain) AVPlayer *player;
@property (nonatomic) CMTime timeToResume;
@property (nonatomic,retain) id periodicTimeObserver;
@property (nonatomic) BOOL shouldResumeOnAppActive;
@end

@implementation YYKVideoPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL delegate:(id<YYKVideoPlayerDelegate>)delegate {
    self = [self init];
    if (self) {
        _videoURL = videoURL;
        _delegate = delegate;
        
        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.text = @"加载中...";
        _loadingLabel.textColor = [UIColor whiteColor];
        _loadingLabel.font = [UIFont systemFontOfSize:14.];
        [self addSubview:_loadingLabel];
        {
            [_loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
        }
        
        self.player = [AVPlayer playerWithURL:videoURL];
        [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
        
        @weakify(self);
        self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            @strongify(self);
            
            if (!self) {
                return ;
            }
            
            if (!CMTIME_IS_NUMERIC(time) || !CMTIME_IS_NUMERIC(self.player.currentItem.duration)) {
                return ;
            }
            
            if ([self.delegate respondsToSelector:@selector(videoPlayer:playingVideoInSeconds:withDuration:)]) {
                CGFloat currentSecond = CMTimeGetSeconds(time);
                CGFloat duration = CMTimeGetSeconds(self.player.currentItem.duration);
                
                [self.delegate videoPlayer:self playingVideoInSeconds:currentSecond withDuration:duration];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPlay) name:AVPlayerItemDidPlayToEndTimeNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)startToPlay {
    [self.player play];
    self.shouldResumeOnAppActive = YES;
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidStartPlayVideo:)]) {
        [self.delegate videoPlayerDidStartPlayVideo:self];
    }
}

- (void)pause {
    [self.player pause];
    self.shouldResumeOnAppActive = NO;
}

- (void)dealloc {
    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:self.periodicTimeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    DLog(@"%@ dealloc!", [self class]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusReadyToPlay:
                _loadingLabel.hidden = YES;
                
//                if ([self.delegate respondsToSelector:@selector(videoPlayer:didStartPlayVideoWithDuration:)]) {
//                    [self.delegate videoPlayer:self didStartPlayVideoWithDuration:_duration];
//                }
                break;
            default:
                _loadingLabel.hidden = NO;
                _loadingLabel.text = @"加载失败";
                break;
        }
    }
}

- (CGFloat)duration {
    if (CMTIME_IS_NUMERIC(self.player.currentItem.duration)) {
        return CMTimeGetSeconds(self.player.currentItem.duration);
    }
    return 0;
}

- (void)didEndPlay {
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidEndPlayVideo:)]) {
        [self.delegate videoPlayerDidEndPlayVideo:self];
    }
}

- (void)applicationWillResignActive {
    [self pause];
    _timeToResume = self.player.currentTime;
}

- (void)applicationDidBecomeActive {
    if (!self.shouldResumeOnAppActive) {
        return ;
    }
    
    @weakify(self);
    [self.player seekToTime:_timeToResume toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        @strongify(self);
        [self startToPlay];
    }];
    
}
@end
