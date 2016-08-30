//
//  YYKSVIPPopView.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYKSVIPPopView;

@protocol YYKSVIPPopViewDelegate <NSObject>

@optional
- (BOOL)popViewShouldAnimateWhenHiding:(YYKSVIPPopView *)popView;
- (void)popViewDidFinishAnimatingForHiding:(YYKSVIPPopView *)popView;
- (CGRect)popViewAnimatingTargetRectForHiding:(YYKSVIPPopView *)popView;
@end

@interface YYKSVIPPopView : UIView

@property (nonatomic,weak) id<YYKSVIPPopViewDelegate> delegate;

+ (instancetype)showPopViewInWindowWithDelegate:(id<YYKSVIPPopViewDelegate>)delegate;
+ (BOOL)hasShown;
- (void)showInWindow;

@end
