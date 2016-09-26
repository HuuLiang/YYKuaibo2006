//
//  YYKVideoPlayerViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoPlayerViewController.h"
#import "YYKVideoPlayer.h"
#import "YYKPaymentViewController.h"

@interface YYKVideoPlayerViewController () <YYKVideoPlayerDelegate>
{
    YYKVideoPlayer *_videoPlayer;
    UIButton *_closeButton;
    
    UIView *_controlView;
    UILabel *_playedSecLabel;
    UISlider *_progressSlider;
}
@end

@implementation YYKVideoPlayerViewController

- (instancetype)initWithVideo:(YYKProgram *)video {
    self = [self init];
    if (self) {
        _video = video;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    @weakify(self);
    _controlView = [[UIView alloc] init];
    _controlView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:_controlView];
    {
        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.height.mas_equalTo(50);
        }];
    }

    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_controlView addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(_controlView);
            make.width.equalTo(_closeButton.mas_height);
        }];
    }
    
    [_closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        SafelyCallBlock(self.closeAction, self);
    } forControlEvents:UIControlEventTouchUpInside];
    
    const CGSize thumbSize = CGSizeMake(15, 15);
    UIGraphicsBeginImageContextWithOptions(thumbSize, NO, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(currentContext, CGRectMake(0, 0, thumbSize.width, thumbSize.height));
    CGContextSetFillColorWithColor(currentContext, [UIColor whiteColor].CGColor);
    CGContextFillPath(currentContext);
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _progressSlider = [[UISlider alloc] init];
    [_progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    _progressSlider.maximumValue = 60 * 10;
    _progressSlider.continuous = NO;
    _progressSlider.enabled = NO;
    [_controlView addSubview:_progressSlider];
    {
        [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_closeButton.mas_right).offset(kLeftRightContentMarginSpacing);
            make.right.equalTo(_controlView).offset(-kLeftRightContentMarginSpacing);
            make.centerY.equalTo(_controlView);
        }];
    }
    
    [_progressSlider bk_addEventHandler:^(id sender) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_videoPlayer pause];
        
        [UIAlertView bk_showAlertViewWithTitle:@"只有VIP会员用户才可以控制播放进度，是否购买VIP会员？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            @strongify(self);
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确认"]) {
                SafelyCallBlock(self.playEndAction, self);
            } else {
                [self->_videoPlayer startToPlay];
            }
        }];
    } forControlEvents:UIControlEventValueChanged];
    
    [self.view beginProgressingWithTitle:@"加载中..." subtitle:nil];
    [[YYKVideoTokenManager sharedManager] requestTokenWithCompletionHandler:^(BOOL success, NSString *token, NSString *userId) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self.view endProgressing];
        
        if (success) {
            [self loadVideo:[NSURL URLWithString:[[YYKVideoTokenManager sharedManager] videoLinkWithOriginalLink:self.video.videoUrl]]];
        } else {
            [UIAlertView bk_showAlertViewWithTitle:@"无法获取视频信息" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
     
    
}

- (void)loadVideo:(NSURL *)videoUrl {

    _videoPlayer = [[YYKVideoPlayer alloc] initWithVideoURL:videoUrl delegate:self];
    [self.view insertSubview:_videoPlayer atIndex:0];
    {
        [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
#ifdef YYK_DISPLAY_VIDEO_URL
    NSString *url = videoUrl.absoluteString;
    [UIAlertView bk_showAlertViewWithTitle:@"视频链接" message:url cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_videoPlayer startToPlay];
}

- (void)pause {
    [_videoPlayer pause];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YYKVideoPlayerDelegate

- (void)videoPlayerDidStartPlayVideo:(YYKVideoPlayer *)videoPlayer {
    _progressSlider.enabled = YES;
}

- (void)videoPlayerDidEndPlayVideo:(YYKVideoPlayer *)videoPlayer {
    
    @weakify(self);
    CGFloat duration = videoPlayer.duration == 0 ? 20 : videoPlayer.duration;
    [UIAlertView bk_showAlertViewWithTitle:[NSString stringWithFormat:@"非VIP用户只能观看此视频的前%ld秒，成为VIP后可观看完整视频", (unsigned long)duration] message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        @strongify(self);
        SafelyCallBlock(self.playEndAction, self);
    }];
    
}

- (void)videoPlayer:(YYKVideoPlayer *)videoPlayer playingVideoInSeconds:(CGFloat)seconds withDuration:(CGFloat)duration {
//    _progressSlider.maximumValue = duration;
    [_progressSlider setValue:seconds animated:YES];
}
@end
