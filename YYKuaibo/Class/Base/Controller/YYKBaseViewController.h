//
//  YYKBaseViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKBaseViewController : UIViewController

@property (nonatomic,retain) UIImage *backgroundImage;

- (void)switchToPlayProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel;
- (void)switchToPlayProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel
           shouldShowDetail:(BOOL)shouldShowDetail;
//- (void)playVideo:(YYKVideo *)video;
//- (void)playVideo:(YYKVideo *)video withCloseAction:(YYKAction)closeAction;
//- (void)playVideo:(YYKVideo *)video withTimeControl:(BOOL)hasTimeControl shouldPopPayment:(BOOL)shouldPopPayment;

//- (void)payForProgram:(YYKProgram *)program programLocation:(NSUInteger)programLocation inChannel:(YYKChannel *)channel;
- (void)payForPayPointType:(YYKPayPointType)payPointType;
- (void)payForProgram:(YYKProgram *)program programLocation:(NSUInteger)programLocation inChannel:(YYKChannel *)channel;
//- (void)onPaidNotification:(NSNotification *)notification;

//- (BOOL)shouldDisplayBackgroundImage;

// Override this method to specify sub index
- (NSUInteger)currentIndex;
@end
