//
//  YYKVideoPlayerViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoPlayerViewController.h"
#import "YYKVideoPlayer.h"
#import "YYKVideo.h"
#import "YYKPaymentViewController.h"

@interface YYKVideoPlayerViewController ()
{
    YYKVideoPlayer *_videoPlayer;
    UIButton *_closeButton;
}
@end

@implementation YYKVideoPlayerViewController

- (instancetype)initWithVideo:(YYKVideo *)video {
    self = [self init];
    if (self) {
        _video = video;
        _shouldPopupPaymentIfNotPaid = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    @weakify(self);
    _videoPlayer = [[YYKVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:self.video.videoUrl]];
    _videoPlayer.endPlayAction = ^(id sender) {
        @strongify(self);
        [self dismissAndPopPayment];
    };
    [self.view addSubview:_videoPlayer];
    {
        [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(30);
        }];
    }
    
    [_closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self->_videoPlayer pause];
        
        [self dismissAndPopPayment];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_videoPlayer startToPlay];
}

- (void)dismissAndPopPayment {
    [[YYKPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:(YYKProgram *)self.video withCompletionHandler:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAll;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
