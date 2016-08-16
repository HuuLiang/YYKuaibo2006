//
//  YYKHomeRankingHeaderView.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeRankingHeaderView.h"

@interface YYKHomeRankingHeaderView ()
{
    UIView *_contentView;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_iconImageView;
}
@end

@implementation YYKHomeRankingHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        {
            [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.top.equalTo(self).offset(5);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kBigFont;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(kMediumHorizontalSpacing);
                make.centerY.equalTo(self);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = kMediumFont;
        _subtitleLabel.textColor = _titleLabel.textColor;
        [self addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-kMediumHorizontalSpacing);
                make.centerY.equalTo(self);
            }];
        }
        
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ranking_icon"]];
        [self addSubview:_iconImageView];
        {
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_subtitleLabel.mas_left).offset(-kSmallHorizontalSpacing);
                make.centerY.equalTo(self);
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
