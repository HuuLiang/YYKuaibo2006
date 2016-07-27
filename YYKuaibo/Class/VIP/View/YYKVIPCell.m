//
//  YYKVIPCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPCell.h"

static const CGFloat kThumbImageScale = 7./9.;

@interface YYKVIPCell ()
@property (nonatomic,retain) UIImageView *thumbImageView;
@end

@implementation YYKVIPCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_background"]];
    }
    return self;
}

- (UIImageView *)thumbImageView {
    if (_thumbImageView) {
        return _thumbImageView;
    }
    
    _thumbImageView = [[UIImageView alloc] init];
    [self addSubview:_thumbImageView];
    {
        [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.8);
            make.height.equalTo(_thumbImageView.mas_width).dividedBy(kThumbImageScale);
        }];
    }
    return _thumbImageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _thumbImageView.layer.shadowOpacity = 0.5;
    _thumbImageView.layer.shadowOffset = CGSizeMake(-3, -3);
    _thumbImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_thumbImageView.bounds].CGPath;
    
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [self.thumbImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder_1_1"]];
}

@end
