//
//  YYKVIPVideoCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPVideoCell.h"

@interface YYKVIPVideoCell ()
{
    UIImageView *_thumbImageView;
    UILabel *_titleLabel;
    UIImageView *_playIconImageView;
}
@end

@implementation YYKVIPVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kMediumFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(kMediumHorizontalSpacing);
                make.right.equalTo(self).offset(-kMediumHorizontalSpacing);
                make.bottom.equalTo(self);
                make.height.mas_equalTo([[self class] titleHeight]);
            }];
        }
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.bottom.equalTo(_titleLabel.mas_top);
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
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:self.placeholderImage];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

+ (CGFloat)titleHeight {
    return 30;
}

+ (CGFloat)heightRelativeToWidth:(CGFloat)width withImageScale:(CGFloat)imageScale {
    if (imageScale == 0) {
        return [self titleHeight];
    }
    
    return width / imageScale + [self titleHeight];
}
@end
