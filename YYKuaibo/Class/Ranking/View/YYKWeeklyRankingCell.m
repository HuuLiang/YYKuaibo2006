//
//  YYKWeeklyRankingCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKWeeklyRankingCell.h"

@interface YYKWeeklyRankingCell ()
{
    UIImageView *_thumbImageView;
    
    UIImageView *_tagImageView;
    UILabel *_tagLabel;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    UIImageView *_popIconImageView;
    UILabel *_popLabel;
}
@end

@implementation YYKWeeklyRankingCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *rightView = [[UIView alloc] init];
        [self addSubview:rightView];
        {
            [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.right.equalTo(self);
                make.width.equalTo(rightView.mas_height).multipliedBy([[self class] rightViewScale]);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kDefaultTextColor;
        _titleLabel.font = kMediumFont;
        [rightView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(rightView).offset(kTopBottomContentMarginSpacing);
                make.left.equalTo(rightView).offset(kLeftRightContentMarginSpacing);
                make.right.equalTo(rightView).offset(-kLeftRightContentMarginSpacing);
                make.height.mas_equalTo(_titleLabel.font.pointSize);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = _titleLabel.textColor;
        _subtitleLabel.font = kSmallFont;
        _subtitleLabel.numberOfLines = 3;
        [rightView addSubview:_subtitleLabel];

        _popIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popularity_icon"]];
        _popIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [rightView addSubview:_popIconImageView];
        {
            [_popIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.bottom.equalTo(rightView).offset(-kTopBottomContentMarginSpacing);
                make.width.equalTo(rightView).multipliedBy(0.15);
                make.height.equalTo(_popIconImageView.mas_width).multipliedBy(_popIconImageView.image.size.height/_popIconImageView.image.size.width);
            }];
            
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_titleLabel);
                make.bottom.equalTo(_popIconImageView.mas_top).offset(-kMediumVerticalSpacing);
                make.top.equalTo(_titleLabel.mas_bottom).offset(kMediumVerticalSpacing);
            }];
        }
        
        _popLabel = [[UILabel alloc] init];
        _popLabel.textColor = kDefaultLightTextColor;
        _popLabel.font = kSmallFont;
        [rightView addSubview:_popLabel];
        {
            [_popLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_popIconImageView.mas_right).offset(kSmallHorizontalSpacing);
                make.right.equalTo(_titleLabel);
                make.centerY.equalTo(_popIconImageView);
            }];
        }
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.clipsToBounds = YES;
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.image = [UIImage imageNamed:@"placeholder_1_1"];
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(self);
                make.right.equalTo(rightView.mas_left);
            }];
        }
        
        _tagImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ranking_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _tagImageView.tintColor = kDefaultTextColor;
        _tagImageView.hidden = YES;
        [self addSubview:_tagImageView];
        {
            [_tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.top.equalTo(self).offset(10);
                make.size.mas_equalTo(CGSizeMake(40, 22));
            }];
        }
        
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.font = kSmallFont;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        [_tagImageView addSubview:_tagLabel];
        {
            [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_tagImageView);
            }];
        }
    }
    return self;
}

- (void)setTagName:(NSString *)tagName {
    _tagName = tagName;
    _tagLabel.text = tagName;
    _tagImageView.hidden = tagName.length == 0;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder_1_1"]];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

+ (CGFloat)rightViewScale {
    return 1.1 / 1.;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _attributedTitle = attributedTitle;
    _titleLabel.attributedText = attributedTitle;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
}

- (void)setPopularity:(NSUInteger)popularity {
    _popularity = popularity;
    _popLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)popularity];
}

+ (CGFloat)widthRelativeToHeight:(CGFloat)height withImageScale:(CGFloat)imageScale {
    if (imageScale == 0) {
        return height;
    }
    
    return height * imageScale + height / [self rightViewScale];
}
@end
