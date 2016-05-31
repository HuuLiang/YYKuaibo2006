//
//  YYKCard.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/21.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCard.h"

@interface YYKCard ()
{
    UIImageView *_thumbImageView;
    UILabel *_titleLabel;
    UIImageView *_vipIconImageView;
    UILabel *_subtitleLabel;
}
@end

@implementation YYKCard

- (instancetype)init {
    self = [super init];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [_thumbImageView YPB_addAnimationForImageAppearing];
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _titleLabel.layer.cornerRadius = 4;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self).offset(-15);
            }];
        }
        
        UIImage *image = [UIImage imageNamed:@"vip_grey_diamond"];
        _vipIconImageView = [[UIImageView alloc] init];
        [self addSubview:_vipIconImageView];
        {
            [_vipIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-15);
                make.top.equalTo(self).offset(15);
                make.width.mas_equalTo(44);
                make.height.equalTo(_vipIconImageView.mas_width).multipliedBy(image.size.height/image.size.width);
            }];
        }
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    @weakify(self);
    [_thumbImageView sd_setImageWithURL:imageURL
                       placeholderImage:self.placeholderImage
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
        @strongify(self);
        if (image) {
            _vipIconImageView.image = self.lightedDiamond ? [UIImage imageNamed:@"vip_lighted_diamond"] : [UIImage imageNamed:@"vip_grey_diamond"];
        }
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    
    if (subtitle.length > 0 && !_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.layer.cornerRadius = 4;
        _subtitleLabel.layer.masksToBounds = YES;
        _subtitleLabel.backgroundColor = _titleLabel.backgroundColor;
        _subtitleLabel.textColor = _titleLabel.textColor;
        _subtitleLabel.font = [UIFont systemFontOfSize:16];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.numberOfLines = 2;
        [self addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
 //               make.top.equalTo(_titleLabel.mas_bottom).offset(5);
                make.centerX.equalTo(self);
                make.left.greaterThanOrEqualTo(self).offset(15);
                make.right.lessThanOrEqualTo(self).offset(-15);
                make.bottom.lessThanOrEqualTo(self).offset(-15);
            }];
        }
        
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(_subtitleLabel.mas_top).offset(-5);
        }];
    }
    
    _subtitleLabel.text = subtitle;
    _subtitleLabel.hidden = subtitle.length == 0;
}

- (void)setLightedDiamond:(BOOL)lightedDiamond {
    if (_lightedDiamond == lightedDiamond) {
        return ;
    }
    
    _lightedDiamond = lightedDiamond;
    if (_thumbImageView.image) {
        _vipIconImageView.image = lightedDiamond ? [UIImage imageNamed:@"vip_lighted_diamond"] : [UIImage imageNamed:@"vip_grey_diamond"];
    }
}
@end
