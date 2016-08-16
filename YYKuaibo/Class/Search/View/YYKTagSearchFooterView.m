//
//  YYKTagSearchFooterView.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKTagSearchFooterView.h"

@interface YYKTagSearchFooterView ()
@property (nonatomic,retain) UILabel *textLabel;
@property (nonatomic,retain) UIImageView *imageView;
@end

@implementation YYKTagSearchFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        [self bk_whenTapped:^{
            @strongify(self);
            SafelyCallBlock(self.tapAction, self);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat fullWidth = CGRectGetWidth(self.bounds);
    const CGFloat fullHeight = CGRectGetHeight(self.bounds);
    
    _textLabel.frame = self.bounds;
    _imageView.center = CGPointMake(fullWidth/2, fullHeight/2);
    _imageView.bounds = CGRectMake(0, 0, fullHeight*0.5, fullHeight*0.5);
}

- (UILabel *)textLabel {
    if (_textLabel) {
        return _textLabel;
    }
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.textColor = kThemeColor;
    _textLabel.font = kMediumFont;
    _textLabel.text = @"清空记录";
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    return _textLabel;
}

- (UIImageView *)imageView {
    if (_imageView) {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.transform = self.imageTransform;
    [self addSubview:_imageView];
    return _imageView;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    if (title.length > 0) {
        self.textLabel.text = title;
        self.textLabel.hidden = NO;
        _imageView.hidden = YES;
    } else {
        _textLabel.hidden = YES;
    }
    
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    if (image) {
        self.imageView.image = image;
        self.imageView.hidden = NO;
        _textLabel.hidden = YES;
    } else {
        _imageView.hidden = YES;
    }
    
}

- (void)setImageTransform:(CGAffineTransform)imageTransform {
    _imageTransform = imageTransform;
    
    _imageView.transform = imageTransform;
}
@end
