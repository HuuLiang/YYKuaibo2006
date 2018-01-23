//
//  YYKCategoryRoundImageCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCategoryRoundImageCell.h"

#define _titleFont kBigFont
#define _popFont kSmallFont
#define _imageWidthAspect (0.75)
#define _interImageAndTitleSpacing (8)
#define _interTitleAndPopSpacing (5)

@interface YYKCategoryRoundImageCell ()
{
    UILabel *_titleLabel;
    UIImageView *_thumbImageView;
    UILabel *_popLabel;
}
@end

@implementation YYKCategoryRoundImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = _titleFont;
        _titleLabel.textColor = kDefaultTextColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _popLabel = [[UILabel alloc] init];
        _popLabel.textColor = kDefaultLightTextColor;
        _popLabel.font = _popFont;
        _popLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_popLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat fullWidth = self.bounds.size.width;
//    const CGFloat fullHeight = self.bounds.size.height;
    
    const CGFloat imageWidth = fullWidth * _imageWidthAspect;
    const CGFloat imageX = (fullWidth - imageWidth)/2;
    _thumbImageView.frame = CGRectMake(imageX, 0, imageWidth, imageWidth);
    _thumbImageView.layer.cornerRadius = imageWidth / 2;
    
    const CGFloat titleWidth = fullWidth * 0.9;
    const CGFloat titleX = (fullWidth - titleWidth)/2;
    const CGFloat titleHeight = _titleFont.pointSize;
    const CGFloat titleY = CGRectGetMaxY(_thumbImageView.frame) + _interImageAndTitleSpacing;
    _titleLabel.frame = CGRectMake(titleX, titleY, titleWidth, titleHeight);
    
    _popLabel.frame = CGRectMake(titleX, CGRectGetMaxY(_titleLabel.frame)+_interTitleAndPopSpacing, titleWidth, _popFont.pointSize);
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setPopularity:(NSUInteger)popularity {
    _popularity = popularity;
    
    if (popularity == 0) {
        _popLabel.hidden = YES;
    } else {
        _popLabel.hidden = NO;
    }
    
    if (popularity / 10000 > 0) {
        _popLabel.text = [NSString stringWithFormat:@"%.1f万观看", popularity/10000.];
    } else {
        _popLabel.text = [NSString stringWithFormat:@"%ld观看", (unsigned long)popularity];
    }
    
}

+ (CGFloat)cellHeightRelativeToWidth:(CGFloat)width {
    return width * _imageWidthAspect +_interImageAndTitleSpacing + _interTitleAndPopSpacing + _titleFont.pointSize + _popFont.pointSize + 10;
}
@end
