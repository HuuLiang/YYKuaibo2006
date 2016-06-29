//
//  YYKCard.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/21.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCard.h"

#define kInnerInsets (6)

@interface YYKCard ()
{
    UIImageView *_thumbImageView;
    
    UIView *_bottomView;
    UILabel *_titleLabel;
    UILabel *_rankLabel;
    UIImageView *_vipIconImageView;
//    UILabel *_subtitleLabel;
    UILabel *_popularityLabel;
}
@end

@implementation YYKCard

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        _thumbImageView.layer.cornerRadius = 5;
        [_thumbImageView YPB_addAnimationForImageAppearing];
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.equalTo(self).offset(kInnerInsets);
                make.right.equalTo(self).offset(-kInnerInsets);
                make.height.equalTo(_thumbImageView.mas_width).multipliedBy(9./7.);
            }];
        }
        
        UIImage *image = [UIImage imageNamed:@"vip_grey_diamond"];
        _vipIconImageView = [[UIImageView alloc] init];
        [_thumbImageView addSubview:_vipIconImageView];
        {
            [_vipIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_thumbImageView).offset(-15);
                make.top.equalTo(_thumbImageView).offset(15);
                make.width.mas_equalTo(44);
                make.height.equalTo(_vipIconImageView.mas_width).multipliedBy(image.size.height/image.size.width);
            }];
        }
        
        _bottomView = [[UIView alloc] init];
        [self addSubview:_bottomView];
        {
            [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_thumbImageView);
                make.top.equalTo(_thumbImageView.mas_bottom).offset(kInnerInsets);
                make.bottom.equalTo(self).offset(-kInnerInsets);
            }];
        }
        
        _rankLabel = [[UILabel alloc] init];
        _rankLabel.textColor = [UIColor whiteColor];
        _rankLabel.backgroundColor = [UIColor darkPink];
        _rankLabel.textAlignment = NSTextAlignmentCenter;
        _rankLabel.clipsToBounds = YES;
        _rankLabel.hidden = YES;
        [_rankLabel aspect_hookSelector:@selector(layoutSubviews)
                            withOptions:AspectPositionAfter
                             usingBlock:^(id<AspectInfo> aspectInfo)
        {
            UILabel *thisLabel = [aspectInfo instance];
            thisLabel.layer.cornerRadius = CGRectGetHeight(thisLabel.frame)/2;
            thisLabel.font = [UIFont systemFontOfSize:CGRectGetHeight(thisLabel.frame)/1.8];
        } error:nil];
        [_bottomView addSubview:_rankLabel];
        {
            [_rankLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_bottomView).offset(-5);
                make.centerY.equalTo(_bottomView);
                make.height.equalTo(_bottomView).multipliedBy(0.5);
                make.width.equalTo(_rankLabel.mas_height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:MIN(kScreenHeight/30.,20)];
        [_bottomView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_bottomView);
                make.right.equalTo(_rankLabel.mas_left).offset(-5);
                make.bottom.equalTo(_bottomView.mas_centerY);
            }];
        }
        
//        _subtitleLabel = [[UILabel alloc] init];
//        _subtitleLabel.font = [UIFont systemFontOfSize:_titleLabel.font.pointSize-2];
//        _subtitleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
//        [_bottomView addSubview:_subtitleLabel];
//        {
//            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.equalTo(_titleLabel);
//                make.top.equalTo(_titleLabel.mas_bottom).offset(MIN(kScreenHeight*0.005,5));
//            }];
//        }
        
        _popularityLabel = [[UILabel alloc] init];
        _popularityLabel.font = [UIFont systemFontOfSize:_titleLabel.font.pointSize-2];
        _popularityLabel.textColor = [UIColor redColor];
        [_bottomView addSubview:_popularityLabel];
        {
            [_popularityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(MIN(kScreenHeight*0.005,5));
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

//- (void)setSubtitle:(NSString *)subtitle {
//    _subtitle = subtitle;
//    
//    _subtitleLabel.text = subtitle;
//    _subtitleLabel.hidden = subtitle.length == 0;
//}

- (void)setLightedDiamond:(BOOL)lightedDiamond {
    if (_lightedDiamond == lightedDiamond) {
        return ;
    }
    
    _lightedDiamond = lightedDiamond;
    if (_thumbImageView.image) {
        _vipIconImageView.image = lightedDiamond ? [UIImage imageNamed:@"vip_lighted_diamond"] : [UIImage imageNamed:@"vip_grey_diamond"];
    }
    
    self.backgroundColor = lightedDiamond ? [UIColor colorWithHexString:@"#fffc79"] : [UIColor whiteColor];
//    _rankLabel.backgroundColor = lightedDiamond ? [UIColor whiteColor] : [UIColor darkPink];
//    _rankLabel.textColor = lightedDiamond ? [UIColor darkPink] : [UIColor whiteColor];
}

- (void)setRank:(NSUInteger)rank {
    _rank = rank;
    _rankLabel.text = @(rank).stringValue;
    _rankLabel.hidden = rank == 0;
}

- (void)setPopularity:(NSUInteger)popularity {
    _popularity = popularity;
    
    _popularityLabel.text = [NSString stringWithFormat:@"热度：%ld", (unsigned long)popularity];
}
@end
