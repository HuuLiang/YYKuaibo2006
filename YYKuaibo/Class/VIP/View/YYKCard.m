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
}
@end

@implementation YYKCard

- (instancetype)init {
    self = [super init];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        [_thumbImageView YPB_addAnimationForImageAppearing];
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        
        _titleLabel = [[UILabel alloc] init];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
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
    [_thumbImageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
