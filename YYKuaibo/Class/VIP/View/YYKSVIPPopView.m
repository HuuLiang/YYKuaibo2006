//
//  YYKSVIPPopView.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSVIPPopView.h"

static NSString *const kSVIPPopViewShownKeyName = @"yykuaibov_svippopview_keyname";

@interface YYKSVIPPopView ()
{
    UIImageView *_contentImageView;
    UIImageView *_textImageView;
    UIButton *_okButton;
}
@end

@implementation YYKSVIPPopView

+ (instancetype)showPopViewInWindowWithDelegate:(id<YYKSVIPPopViewDelegate>)delegate {
    YYKSVIPPopView *popView = [[YYKSVIPPopView alloc] init];
    popView.delegate = delegate;
    [popView showInWindow];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kSVIPPopViewShownKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return popView;
}

+ (BOOL)hasShown {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:kSVIPPopViewShownKeyName];
    return value.boolValue;
}

- (void)dealloc {
    DLog(@"%@ dealloc", [self class]);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        const CGFloat imageScale = 687./377.;
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"svip_popup_background" ofType:@"jpg"];
        _contentImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
        [self addSubview:_contentImageView];
        {
            [_contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.width.equalTo(self).multipliedBy(0.85);
                make.height.equalTo(_contentImageView.mas_width).dividedBy(imageScale);
            }];
        }
        
        _textImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"svip_popup_content"]];
        [self addSubview:_textImageView];
        {
            [_textImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_contentImageView);
                make.top.equalTo(_contentImageView).offset(kTopBottomContentMarginSpacing);
            }];
        }
        
        _okButton = [[UIButton alloc] init];
        [_okButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor colorWithHexString:@"#ab68c1"] forState:UIControlStateNormal];
        [_okButton setTitle:@"我知道了" forState:UIControlStateNormal];
        _okButton.titleLabel.font = kBigFont;
        _okButton.layer.cornerRadius = 5;
        _okButton.layer.masksToBounds = YES;
        [_okButton addTarget:self action:@selector(onOK) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_okButton];
        {
            [_okButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_contentImageView);
                make.top.equalTo(_textImageView.mas_bottom).offset(kTopBottomContentMarginSpacing);
                make.height.equalTo(_contentImageView).multipliedBy(0.2);
                make.width.equalTo(_textImageView).multipliedBy(0.8);//.mas_lessThanOrEqualTo(100);
            }];
        }
    }
    return self;
}

- (void)showInWindow {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.frame = keyWindow.bounds;
    _contentImageView.alpha = 0;
    [keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        _contentImageView.alpha = 1;
    }];
}

- (void)hide {
    if (self.superview) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.backgroundColor = [UIColor clearColor];
            _contentImageView.alpha = 0;
            _okButton.alpha = 0;
            _textImageView.frame = [self askDelegateForTargetRectForAnimating];
        } completion:^(BOOL finished) {
            [self notifyDelegateDidFinishAnimatingForHiding];
            [self removeFromSuperview];
        }];
    }
}

- (void)onOK {
    [self hide];
}

- (BOOL)askDelegateShouldAnimatingWhenHiding {
    if ([self.delegate respondsToSelector:@selector(popViewShouldAnimateWhenHiding:)]) {
        return [self.delegate popViewShouldAnimateWhenHiding:self];
    }
    
    return YES;
}

- (CGRect)askDelegateForTargetRectForAnimating {
    if ([self.delegate respondsToSelector:@selector(popViewAnimatingTargetRectForHiding:)]) {
        return [self.delegate popViewAnimatingTargetRectForHiding:self];
    }
    return CGRectMake(_textImageView.center.x, _textImageView.center.y, 0, 0);
}

- (void)notifyDelegateDidFinishAnimatingForHiding {
    if ([self.delegate respondsToSelector:@selector(popViewDidFinishAnimatingForHiding:)]) {
        [self.delegate popViewDidFinishAnimatingForHiding:self];
    }
}
@end
