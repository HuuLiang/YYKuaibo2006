//
//  YYKHomeSectionHeader.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeSectionHeader.h"

@interface YYKHomeSectionHeader ()
{
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_iconImageView;
}
@end

@implementation YYKHomeSectionHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _titleLabel = [[UILabel alloc] init];
        [_contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        [_contentView addSubview:_subtitleLabel];
        
        _iconImageView = [[UIImageView alloc] init];
        [_contentView addSubview:_iconImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    
    _subtitleLabel.font = [UIFont boldSystemFontOfSize:CGRectGetHeight(_contentView.frame)*0.4];
    _titleLabel.font = _subtitleLabel.font;
    
    const CGSize subtitleSize = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:_subtitleLabel.font}];
    const CGSize titleSize = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}];
    const CGFloat maxSubtitleWidth = CGRectGetWidth(_contentView.bounds) * 0.5;
    const CGSize imageSize = _iconImageView.image.size;
    const CGFloat imageHeight = titleSize.height;
    const CGFloat imageWidth = imageSize.height == 0 ? 0 : imageHeight * imageSize.width / imageSize.height;
    const CGFloat imageInterspacing = 5;
    
    const CGFloat subtitleWidth = MIN(subtitleSize.width, maxSubtitleWidth);
    const CGFloat subtitleHeight = subtitleSize.height;
    const CGFloat subtitleX = CGRectGetMaxX(_contentView.bounds) - subtitleWidth - 5;
    const CGFloat subtitleY = (CGRectGetHeight(_contentView.bounds) - subtitleHeight)/2;
    _subtitleLabel.frame = CGRectMake(subtitleX, subtitleY, subtitleWidth, subtitleHeight);
    
    
    const CGFloat titleX = CGRectGetMinX(_contentView.bounds)+5;
    const CGFloat maxTitleWidth = CGRectGetMinX(_subtitleLabel.frame) - titleX - imageWidth - imageInterspacing * 2;
    const CGFloat titleWidth = MIN(maxTitleWidth, titleSize.width);
    _titleLabel.frame = CGRectMake(titleX,
                                   (CGRectGetHeight(_contentView.bounds)-titleSize.height)/2,
                                   titleWidth, titleSize.height);
    
    _iconImageView.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame)+5,
                                      (CGRectGetHeight(_contentView.bounds)-imageHeight)/2,
                                      imageWidth, imageHeight);
    
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _titleLabel.textColor = textColor;
    _subtitleLabel.textColor = textColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
}

- (void)setIconURL:(NSURL *)iconURL {
    _iconURL = iconURL;
    
    @weakify(self);
    [_iconImageView sd_setImageWithURL:iconURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        [self setNeedsLayout];
    }];
}
@end
