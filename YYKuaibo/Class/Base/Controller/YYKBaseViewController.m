//
//  YYKBaseViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"
#import "YYKProgram.h"
#import "YYKPaymentViewController.h"
#import "YYKVideoPlayerViewController.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

@interface YYKBaseViewController ()
- (UIViewController *)playerVCWithVideo:(YYKVideo *)video;
@end

@implementation YYKBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)switchToPlayProgram:(YYKProgram *)program {
    if (![YYKUtil isPaid]) {
        [self payForProgram:program];
    } else if (program.type.unsignedIntegerValue == YYKProgramTypeVideo) {
        [self playVideo:program];
    }
}

- (void)playVideo:(YYKVideo *)video {
    [self playVideo:video withTimeControl:YES shouldPopPayment:NO];
}

- (void)playVideo:(YYKVideo *)video withTimeControl:(BOOL)hasTimeControl shouldPopPayment:(BOOL)shouldPopPayment {
    if (hasTimeControl) {
        UIViewController *videoPlayVC = [self playerVCWithVideo:video];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    } else {
        YYKVideoPlayerViewController *playerVC = [[YYKVideoPlayerViewController alloc] initWithVideo:video];
        playerVC.hidesBottomBarWhenPushed = YES;
        [self presentViewController:playerVC animated:YES completion:nil];
    }
}

- (void)payForProgram:(YYKProgram *)program {
    [self payForProgram:program inView:self.view.window];
}

- (void)payForProgram:(YYKProgram *)program inView:(UIView *)view {
    [[YYKPaymentViewController sharedPaymentVC] popupPaymentInView:view forProgram:program withCompletionHandler:nil];
}

- (void)onPaidNotification:(NSNotification *)notification {}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)playerVCWithVideo:(YYKVideo *)video {
    UIViewController *retVC;
    if (NSClassFromString(@"AVPlayerViewController")) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:video.videoUrl]];
        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
                          withOptions:AspectPositionAfter
                           usingBlock:^(id<AspectInfo> aspectInfo){
                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
                               [thisPlayerVC.player play];
                           } error:nil];
        
        retVC = playerVC;
    } else {
        retVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoUrl]];
    }
    
    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
        [[aspectInfo originalInvocation] setReturnValue:&mask];
    } error:nil];
    
    [retVC aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        BOOL rotate = YES;
        [[aspectInfo originalInvocation] setReturnValue:&rotate];
    } error:nil];
    return retVC;
}

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
