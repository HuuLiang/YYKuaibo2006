//
//  YYKCategoryAppIconCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCategoryAppIconCell.h"

#define _titleFont kBigFont
#define _imageWidthAspect (0.8)
#define _interTitleAndImageSpacing (5)
#define _downloadLabelHeight (kBigFont.pointSize+5)
#define _interTitleAndDownloadSpacing (8)

@interface YYKCategoryAppIconCell ()
{
    UILabel *_titleLabel;
    UIImageView *_thumbImageView;
    UILabel *_downloadLabel;
}
@end

@implementation YYKCategoryAppIconCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        _thumbImageView.layer.cornerRadius = 8;
        [self addSubview:_thumbImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kDefaultTextColor;
        _titleLabel.font = _titleFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _downloadLabel = [[UILabel alloc] init];
        _downloadLabel.textColor = kDefaultTextColor;
        _downloadLabel.font = _titleFont;
        _downloadLabel.textAlignment = NSTextAlignmentCenter;
        _downloadLabel.text = @"下 载";
        _downloadLabel.layer.borderColor = kDefaultTextColor.CGColor;
        _downloadLabel.layer.borderWidth = 1;
        _downloadLabel.layer.cornerRadius = 3;
        [self addSubview:_downloadLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat fullWidth = self.bounds.size.width;
    
    const CGFloat imageWidth = fullWidth * _imageWidthAspect;
    const CGFloat imageX = (fullWidth - imageWidth)/2;
    _thumbImageView.frame = CGRectMake(imageX, 0, imageWidth, imageWidth);
    
    const CGFloat titleY = CGRectGetMaxY(_thumbImageView.frame) + _interTitleAndImageSpacing;
    const CGFloat titleHeight = _titleFont.pointSize;
    _titleLabel.frame = CGRectMake(imageX, titleY, imageWidth, titleHeight);
    
    _downloadLabel.frame = CGRectMake(imageX, CGRectGetMaxY(_titleLabel.frame)+_interTitleAndDownloadSpacing, imageWidth, _downloadLabelHeight);
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

+ (CGFloat)cellHeightRelativeToWidth:(CGFloat)width {
    return width * _imageWidthAspect + _interTitleAndImageSpacing + _titleFont.pointSize + _interTitleAndDownloadSpacing + _downloadLabelHeight;
}
@end
