//
//  YYKChannelCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelCell.h"

@interface YYKChannelCell ()
{
    UIImageView *_thumbImageView;
    
    UIView *_titleContainerView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    UIView *_leftSeparator;
    UIView *_rightSeparator;
    
    UIImageView *_popImageView;
    UILabel *_popLabel;
    
    UIView *_maskView;
}
@end

@implementation YYKChannelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        [_thumbImageView addSubview:_maskView];
        {
            [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_thumbImageView);
            }];
        }
        
        _titleContainerView = [[UIView alloc] init];
        _titleContainerView.layer.borderWidth = 1;
        _titleContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
        _titleContainerView.hidden = YES;
        [self addSubview:_titleContainerView];
        {
            [_titleContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self).offset(-kTopBottomContentMarginSpacing);
                make.height.equalTo(self).dividedBy(3);
                make.width.equalTo(self).dividedBy(2);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = kExExExBigFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleContainerView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleContainerView).offset(kMediumHorizontalSpacing);
                make.right.equalTo(_titleContainerView).offset(-kMediumHorizontalSpacing);
                make.bottom.equalTo(_titleContainerView.mas_centerY).offset(kSmallVerticalSpacing);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.font = kBigFont;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleContainerView addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_titleContainerView);
                make.top.equalTo(_titleLabel.mas_bottom);
            }];
        }
        
        _leftSeparator = [[UIView alloc] init];
        _leftSeparator.backgroundColor = [UIColor whiteColor];
        [_titleContainerView addSubview:_leftSeparator];
        {
            [_leftSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.right.equalTo(_subtitleLabel.mas_left).offset(-2);
                make.centerY.equalTo(_subtitleLabel);
                make.height.mas_equalTo(0.5);
            }];
        }
        
        _rightSeparator = [[UIView alloc] init];
        _rightSeparator.backgroundColor = _leftSeparator.backgroundColor;
        [_titleContainerView addSubview:_rightSeparator];
        {
            [_rightSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_titleLabel);
                make.left.equalTo(_subtitleLabel.mas_right).offset(2);
                make.centerY.equalTo(_subtitleLabel);
                make.height.mas_equalTo(0.5);
            }];
        }
        
        _popLabel = [[UILabel alloc] init];
        _popLabel.textColor = [UIColor whiteColor];
        _popLabel.font = kSmallFont;
        [self addSubview:_popLabel];
        {
            [_popLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self).multipliedBy(0.25);
                make.right.equalTo(self).offset(-kLeftRightContentMarginSpacing);
            }];
        }
        
        _popImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"channel_popularity"]];
        [self addSubview:_popImageView];
        {
            [_popImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_popLabel.mas_left).offset(-kSmallHorizontalSpacing);
                make.centerY.equalTo(_popLabel);
            }];
        }
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
    
    _titleContainerView.hidden = title.length == 0 && _subtitle.length == 0;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
    
    _leftSeparator.hidden = subtitle.length == 0;
    _rightSeparator.hidden = subtitle.length == 0;
    _titleContainerView.hidden = subtitle.length == 0 && _title.length == 0;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:self.placeholderImage];
}

- (void)setPopularity:(NSUInteger)popularity {
    _popularity = popularity;
    _popLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)popularity];
}
@end
