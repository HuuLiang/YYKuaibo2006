//
//  YYKWeeklyRankingHeaderView.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKWeeklyRankingHeaderView.h"

@interface YYKWeeklyRankingHeaderView ()
{
    UIView *_contentView;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_iconImageView;
}
@end

@implementation YYKWeeklyRankingHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [super setBackgroundColor:kDarkBackgroundColor];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = kLightBackgroundColor;
        [self addSubview:_contentView];
        {
            [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.top.equalTo(self).offset(15);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kBigFont;
        _titleLabel.textColor = kDefaultTextColor;
        [_contentView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_contentView).offset(kMediumHorizontalSpacing);
                make.centerY.equalTo(_contentView);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = kMediumFont;
        _subtitleLabel.textColor = _titleLabel.textColor;
        [_contentView addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_contentView).offset(-kMediumHorizontalSpacing);
                make.centerY.equalTo(_contentView);
            }];
        }
        
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ranking_icon"]];
        [_contentView addSubview:_iconImageView];
        {
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_subtitleLabel.mas_left).offset(-kSmallHorizontalSpacing);
                make.centerY.equalTo(_contentView);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
}
@end
