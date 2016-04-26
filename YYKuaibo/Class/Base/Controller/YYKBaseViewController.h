//
//  YYKBaseViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYKProgram;
@class YYKVideo;

@interface YYKBaseViewController : UIViewController

@property (nonatomic,retain) UIImage *backgroundImage;

- (void)switchToPlayProgram:(YYKProgram *)program;
- (void)playVideo:(YYKVideo *)video;
//- (void)playVideo:(YYKVideo *)video withCloseAction:(YYKAction)closeAction;
- (void)playVideo:(YYKVideo *)video withTimeControl:(BOOL)hasTimeControl shouldPopPayment:(BOOL)shouldPopPayment;

- (void)payForProgram:(YYKProgram *)program;
- (void)payForPayPointType:(YYKPayPointType)payPointType;
//- (void)onPaidNotification:(NSNotification *)notification;

- (BOOL)shouldDisplayBackgroundImage;

@end
