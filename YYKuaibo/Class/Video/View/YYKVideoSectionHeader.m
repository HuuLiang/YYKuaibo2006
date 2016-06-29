//
//  YYKVideoSectionHeader.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoSectionHeader.h"

@interface YYKVideoSectionHeader ()
{
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_iconImageView;
    UIImageView *_accessoryImageView;
}
@end

@implementation YYKVideoSectionHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        {
            [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 5, 0, 5));
            }];
        }
        
        _iconImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"section_title_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_contentView addSubview:_iconImageView];
        {
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_contentView).offset(5);
                make.centerY.equalTo(_contentView);
                make.height.equalTo(_contentView).multipliedBy(0.5);
                make.width.equalTo(_iconImageView.mas_height).multipliedBy(_iconImageView.image.size.width/_iconImageView.image.size.height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        [_contentView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_iconImageView.mas_right).offset(5);
                make.centerY.equalTo(_contentView);
            }];
        }
        
        _accessoryImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"section_accessory"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_contentView addSubview:_accessoryImageView];
        {
            [_accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_contentView).offset(-5);
                make.centerY.equalTo(_contentView);
                make.height.equalTo(_contentView).multipliedBy(0.4);
                make.width.equalTo(_accessoryImageView.mas_height).multipliedBy(_accessoryImageView.image.size.width/_accessoryImageView.image.size.height);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor lightGrayColor];
        [_contentView addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_accessoryImageView.mas_left).offset(-5);
                make.centerY.equalTo(_contentView);
                make.left.equalTo(_titleLabel.mas_right).priority(MASLayoutPriorityFittingSizeLevel);
            }];
        }
        
        @weakify(self);
        [self bk_whenTapped:^{
            @strongify(self);
            SafelyCallBlock(self.accessoryAction, self);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    _contentView.frame = self.bounds;
    
    _subtitleLabel.font = [UIFont boldSystemFontOfSize:CGRectGetHeight(_contentView.frame)*0.4];
    _titleLabel.font = [UIFont systemFontOfSize:_subtitleLabel.font.pointSize+1];
    
//    const CGSize subtitleSize = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:_subtitleLabel.font}];
//    const CGSize titleSize = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}];
//    const CGFloat maxSubtitleWidth = CGRectGetWidth(_contentView.bounds) * 0.5;
//    const CGSize imageSize = _iconImageView.image.size;
//    const CGFloat imageHeight = titleSize.height;
//    const CGFloat imageWidth = imageSize.height == 0 ? 0 : imageHeight * imageSize.width / imageSize.height;
//    const CGFloat imageInterspacing = 5;
//    
//    const CGFloat subtitleWidth = MIN(subtitleSize.width, maxSubtitleWidth);
//    const CGFloat subtitleHeight = subtitleSize.height;
//    const CGFloat subtitleX = CGRectGetMaxX(_contentView.bounds) - subtitleWidth - 5;
//    const CGFloat subtitleY = (CGRectGetHeight(_contentView.bounds) - subtitleHeight)/2;
//    _subtitleLabel.frame = CGRectMake(subtitleX, subtitleY, subtitleWidth, subtitleHeight);
//    
//    
//    const CGFloat titleX = CGRectGetMinX(_contentView.bounds)+5;
//    const CGFloat maxTitleWidth = CGRectGetMinX(_subtitleLabel.frame) - titleX - imageWidth - imageInterspacing * 2;
//    const CGFloat titleWidth = MIN(maxTitleWidth, titleSize.width);
//    _titleLabel.frame = CGRectMake(titleX,
//                                   (CGRectGetHeight(_contentView.bounds)-titleSize.height)/2,
//                                   titleWidth, titleSize.height);
//    
//    _iconImageView.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame)+5,
//                                      (CGRectGetHeight(_contentView.bounds)-imageHeight)/2,
//                                      imageWidth, imageHeight);
    
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
}

- (void)setIconColor:(UIColor *)iconColor {
    _iconColor = iconColor;
    
    _iconImageView.tintColor = iconColor;
}

- (void)setAccessoryTintColor:(UIColor *)accessoryTintColor {
    _accessoryTintColor = accessoryTintColor;
    _accessoryImageView.tintColor = accessoryTintColor;
}

- (void)setAccessoryHidden:(BOOL)accessoryHidden {
    _accessoryHidden = accessoryHidden;
    _accessoryImageView.hidden = accessoryHidden;
}
@end
