//
//  YYKVideoThumbCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoThumbCell.h"

@interface  YYKVideoThumbCell ()
{
    UIImageView *_thumbImageView;
    UIImageView *_progressImageView;
    UIImageView *_playIconImageView;
}
@end

@implementation YYKVideoThumbCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_1_1"]];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _playIconImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"video_thumb_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _playIconImageView.tintColor = kThemeColor;
        [self addSubview:_playIconImageView];
        {
            [_playIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
        }
        
        _progressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_thumb_progress_bar"]];
        [self addSubview:_progressImageView];
        {
            [_progressImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.equalTo(self);
                make.height.equalTo(_progressImageView.mas_width).multipliedBy(_progressImageView.image.size.height/_progressImageView.image.size.width);
            }];
        }
        
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder_1_1"]];
}
@end
