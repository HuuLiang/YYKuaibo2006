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
    UIView *_contentView;
    
    UIImageView *_leftImageView;
    UIImageView *_rightImageView;
    UILabel *_titleLabel;
}
@end

@implementation YYKVideoSectionHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [super setBackgroundColor:kDarkBackgroundColor];
        
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        {
            [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.top.equalTo(self).offset(5);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kDefaultTextColor;
        _titleLabel.text = @"免费试播";
        _titleLabel.font = kBoldBigFont;
        [_contentView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(_contentView);
            }];
        }
        
        _leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trial_header_icon"]];
        [_contentView addSubview:_leftImageView];
        {
            [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_titleLabel.mas_left).offset(-kLeftRightContentMarginSpacing);
                make.centerY.equalTo(_contentView);
            }];
        }
        
        _rightImageView = [[UIImageView alloc] initWithImage:_leftImageView.image];
        [_contentView addSubview:_rightImageView];
        {
            [_rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel.mas_right).offset(kLeftRightContentMarginSpacing);
                make.centerY.equalTo(_contentView);
            }];
        }
        
        UIView *leftSeparator = [[UIView alloc] init];
        leftSeparator.backgroundColor = kThemeColor;
        [_contentView addSubview:leftSeparator];
        {
            [leftSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_contentView).offset(5);
                make.right.equalTo(_leftImageView.mas_left).offset(-5);
                make.centerY.equalTo(_contentView);
                make.height.mas_equalTo(0.5);
            }];
        }
        
        UIView *rightSeparator = [[UIView alloc] init];
        rightSeparator.backgroundColor = leftSeparator.backgroundColor;
        [_contentView addSubview:rightSeparator];
        {
            [rightSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_rightImageView.mas_right).offset(5);
                make.right.equalTo(_contentView).offset(-5);
                make.centerY.height.equalTo(leftSeparator);
            }];
        }
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _contentView.backgroundColor = backgroundColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}
@end
