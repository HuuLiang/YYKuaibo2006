//
//  YYKLaunchView.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/11.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKLaunchView.h"

@interface YYKLaunchView ()
{
    UIImageView *_imageView;
}
@end

@implementation YYKLaunchView

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        NSString *launchImagePath = [[NSBundle mainBundle] pathForResource:@"launch_image" ofType:@"jpg"];
        _imageView.image = [UIImage imageWithContentsOfFile:launchImagePath];
        [self addSubview:_imageView];
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
    return self;
}

- (void)dealloc {
    DLog(@"YYKLaunchView dealloc");
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if ([keyWindow.subviews containsObject:keyWindow]) {
        return ;
    }
    
    self.frame = keyWindow.bounds;
    [keyWindow addSubview:self];
    
    [UIView animateWithDuration:4 delay:1 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        _imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.25, 1.25);
    } completion:nil];
    
    [UIView animateWithDuration:2 delay:2 options:0 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
