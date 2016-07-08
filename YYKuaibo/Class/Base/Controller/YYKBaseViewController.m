//
//  YYKBaseViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"
#import "YYKPaymentViewController.h"
#import "YYKVideoPlayerViewController.h"
#import "YYKWebViewController.h"
#import "YYKVideoDetailViewController.h"
//@import MediaPlayer;
//@import AVKit;
//@import AVFoundation.AVPlayer;
//@import AVFoundation.AVAsset;
//@import AVFoundation.AVAssetImageGenerator;

@interface YYKBaseViewController ()
{
    UIImageView *_backgroundImageView;
}
@end

@implementation YYKBaseViewController

- (NSUInteger)currentIndex {
    return NSNotFound;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    
    if (self.navigationController.viewControllers.count >= 4) {
        @weakify(self);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"tabbar_home_selected"]
                                                                                     style:UIBarButtonItemStyleDone
                                                                                   handler:^(id sender)
        {
            @strongify(self);
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
//    self.backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"]];
}

//- (void)setBackgroundImage:(UIImage *)backgroundImage {
//    _backgroundImage = backgroundImage;
//    
//    if (![self shouldDisplayBackgroundImage]) {
//        return ;
//    }
//    
//    if (backgroundImage && !_backgroundImageView) {
//        _backgroundImageView = [[UIImageView alloc] init];
//        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
//        [self.view insertSubview:_backgroundImageView atIndex:0];
//        {
//            [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self.view);
//            }];
//        }
//    }
//    _backgroundImageView.image = backgroundImage;
//}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    DLog(@"%@ dealloc", [self class]);
}

- (void)switchToPlayProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel {
    [self switchToPlayProgram:program programLocation:programLocation inChannel:channel shouldShowDetail:YES];
}

- (void)switchToPlayProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel
           shouldShowDetail:(BOOL)shouldShowDetail {
    if (program.type.unsignedIntegerValue == YYKProgramTypeSpread) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:program.videoUrl]];
        shouldShowDetail = NO;
    } else if (program.type.unsignedIntegerValue == YYKProgramTypeVideo) {
        if (channel.type.unsignedIntegerValue == YYKProgramTypeTrial) {
            [self playVideo:program videoLocation:programLocation inChannel:channel withTimeControl:[YYKUtil isVIP] shouldPopPayment:![YYKUtil isVIP]];
            shouldShowDetail = NO;
        } else {
            if (shouldShowDetail) {
                YYKVideoDetailViewController *detailVC = [[YYKVideoDetailViewController alloc] initWithVideo:program
                                                                                               videoLocation:programLocation
                                                                                                   inChannel:channel];
                detailVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailVC animated:YES];
            } else {
                BOOL vipProgramButNoVIP = program.payPointType.unsignedIntegerValue == YYKPayPointTypeVIP && ![YYKUtil isVIP];
                BOOL svipProgramButNoSVIP = program.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP && ![YYKUtil isSVIP];
                if (vipProgramButNoVIP || svipProgramButNoSVIP) {
                    [self payForProgram:program programLocation:programLocation inChannel:channel];
                } else {
                    [self playVideo:program videoLocation:programLocation inChannel:channel withTimeControl:YES shouldPopPayment:NO];
                }
            }
            
        }
    }
    
    [[YYKStatsManager sharedManager] statsCPCWithProgram:program
                                         programLocation:programLocation
                                               inChannel:channel
                                             andTabIndex:[YYKUtil currentTabPageIndex]
                                             subTabIndex:[YYKUtil currentSubTabPageIndex]
                                         isProgramDetail:shouldShowDetail];
}

//- (void)playVideo:(YYKProgram *)video videoLocation {
//    [self playVideo:video withTimeControl:YES shouldPopPayment:NO];
//}

//- (void)playVideo:(YYKProgram *)video withCloseAction:(YYKAction)closeAction {
//    UIViewController *videoPlayVC = [self playerVCWithVideo:video];
//    videoPlayVC.hidesBottomBarWhenPushed = YES;
//    [videoPlayVC aspect_hookSelector:@selector(viewDidDisappear:)
//                         withOptions:AspectPositionAfter
//                          usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated)
//    {
//        if (closeAction) {
//            closeAction([aspectInfo instance]);
//        }
//    } error:nil];
//    [self presentViewController:videoPlayVC animated:YES completion:nil];
//    
//    [video didPlay];
//}

- (void)playVideo:(YYKProgram *)video
    videoLocation:(NSUInteger)videoLocation
        inChannel:(YYKChannel *)channel
  withTimeControl:(BOOL)hasTimeControl
 shouldPopPayment:(BOOL)shouldPopPayment
{
    if (hasTimeControl) {
        YYKWebViewController *webVC = [[YYKWebViewController alloc] initWithURL:[NSURL URLWithString:video.videoUrl] standbyURL:nil];
        webVC.title = video.title;
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
    } else {
        YYKVideoPlayerViewController *playerVC = [[YYKVideoPlayerViewController alloc] initWithVideo:video videoLocation:videoLocation channel:channel];
        playerVC.hidesBottomBarWhenPushed = YES;
        playerVC.shouldPopupPaymentIfNotPaid = shouldPopPayment;
        [self presentViewController:playerVC animated:YES completion:nil];
    }
    
    [video didPlay];
}

- (void)payForProgram:(YYKProgram *)program programLocation:(NSUInteger)programLocation inChannel:(YYKChannel *)channel {
    [[YYKPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window
                                                        forProgram:program
                                                   programLocation:programLocation
                                                         inChannel:channel
                                             withCompletionHandler:nil
                                                      footerAction:^(id obj)
    {
        YYKPaymentViewController *paymentVC = (YYKPaymentViewController *)obj;
        [paymentVC hidePayment];
        
        [[YYKManualActivationManager sharedManager] doActivation];
    }];
}

- (void)payForPayPointType:(YYKPayPointType)payPointType {
    YYKProgram *program = [[YYKProgram alloc] init];
    program.payPointType = @(payPointType);
    [self payForProgram:program programLocation:0 inChannel:nil];
}
//- (void)onPaidNotification:(NSNotification *)notification {}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//- (UIViewController *)playerVCWithVideo:(YYKProgram *)video {
//    UIViewController *retVC;
//    if (NSClassFromString(@"AVPlayerViewController")) {
//        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
//        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:video.videoUrl]];
//        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
//                          withOptions:AspectPositionAfter
//                           usingBlock:^(id<AspectInfo> aspectInfo){
//                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
//                               [thisPlayerVC.player play];
//                           } error:nil];
//        
//        retVC = playerVC;
//    } else {
//        retVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoUrl]];
//    }
//    
//    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
//        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
//        [[aspectInfo originalInvocation] setReturnValue:&mask];
//    } error:nil];
//    
//    [retVC aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
//        BOOL rotate = YES;
//        [[aspectInfo originalInvocation] setReturnValue:&rotate];
//    } error:nil];
//    return retVC;
//}

//- (BOOL)shouldDisplayBackgroundImage {
//    return YES;
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
