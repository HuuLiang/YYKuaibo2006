//
//  YYKBannerItemView.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBannerItemView.h"

@interface YYKBannerItemView ()
{
    UIImageView *_thumbImageView;
    UILabel *_titleLabel;
    UIImageView *_tagImageView;
}
@end

@implementation YYKBannerItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        UIView *footerView = [[UIView alloc] init];
        footerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self addSubview:footerView];
        {
            [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.height.equalTo(self).multipliedBy(0.15);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = kMediumFont;
        [footerView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(footerView);
                make.left.equalTo(footerView).offset(5);
                make.right.equalTo(footerView).offset(-5);
            }];
        }
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder_1_1"]];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setTagImage:(UIImage *)tagImage {
    _tagImage = tagImage;
    
    if (tagImage && !_tagImageView) {
        _tagImageView = [[UIImageView alloc] init];
        [_thumbImageView addSubview:_tagImageView];
        {
            [_tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.top.equalTo(_thumbImageView);
                make.height.equalTo(_thumbImageView).multipliedBy(0.25);
                make.width.equalTo(_tagImageView.mas_height);
            }];
        }
    }
    
    _tagImageView.image = tagImage;
}
@end
