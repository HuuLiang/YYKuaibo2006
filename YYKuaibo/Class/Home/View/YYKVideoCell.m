//
//  YYKVideoCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoCell.h"

@interface YYKVideoCell ()
{
    UIView *_footerView;
    UILabel *_titleLabel;
    UIImageView *_coverImageView;
    UIImageView *_iconImageView;
    UILabel *_specLabel;
}
@end

@implementation YYKVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _footerView = [[UIView alloc] init];
//        _footerView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
        [self addSubview:_footerView];
        {
            [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.height.mas_equalTo([[self class] titleHeight]);
            }];
        }

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15.];
        //_titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        [_footerView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_footerView).offset(5);
                make.centerY.equalTo(_footerView);
                make.right.equalTo(_footerView).offset(-5);
            }];
        }
        
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];
        {
            [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.bottom.equalTo(_footerView.mas_top);
            }];
        }
        
    }
    return self;
}

//+ (CGFloat)heightRelativeToWidth:(CGFloat)width {
//    return width * 1050./825.;
//}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_coverImageView sd_setImageWithURL:imageURL placeholderImage:self.placeholderImage];
}

- (void)setShowPlayIcon:(BOOL)showPlayIcon {
    _showPlayIcon = showPlayIcon;
    
    if (showPlayIcon) {
        if (!_iconImageView) {
            const CGFloat iconHeightScale = 0.75;
            _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_play_icon"]];
            [_footerView addSubview:_iconImageView];
            {
                [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_footerView).offset(5);
                    make.centerY.equalTo(_footerView);
                    make.height.equalTo(_footerView).multipliedBy(iconHeightScale);
                    make.width.equalTo(_iconImageView.mas_height);
                }];
            }
            
            [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_footerView).offset([[self class] titleHeight]*iconHeightScale + 10);
            }];
//            [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(_iconImageView.mas_right).offset(5);
//            }];
        }
    } else {
        if (_iconImageView) {
            [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(5);
            }];
        }
    }
    _iconImageView.hidden = !showPlayIcon;
}

- (void)setSpec:(YYKVideoSpec)spec {
    _spec = spec;
    
    if (spec != YYKVideoSpecNone && !_specLabel) {
        _specLabel = [[UILabel alloc] init];
        _specLabel.textColor = [UIColor whiteColor];
        _specLabel.backgroundColor = [UIColor darkPink];
        _specLabel.font = [UIFont systemFontOfSize:13.];
        _specLabel.textAlignment = NSTextAlignmentCenter;
        _specLabel.layer.cornerRadius = 4;
        _specLabel.layer.masksToBounds = YES;
        [self addSubview:_specLabel];
        {
            [_specLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-10);
                make.top.equalTo(self).offset(10);
                make.size.mas_equalTo(CGSizeMake(30, 16));
            }];
        }
    }
    
    NSString *specText;
    switch (spec) {
        case YYKVideoSpecNew:
            specText = @"最新";
            break;
        case YYKVideoSpecHot:
            specText = @"热门";
            break;
        case YYKVideoSpecHD:
            specText = @"高清";
            break;
        case YYKVideoSpecFree:
            specText = @"试播";
            break;
        case YYKVideoSpecVIP:
            specText = @"黑钻";
            break;
        default:
            break;
    }
    _specLabel.text = specText;
    _specLabel.hidden = specText.length == 0;
}

+ (CGFloat)heightRelativeToWidth:(CGFloat)width withScale:(CGFloat)scale {
    if (scale == 0) {
        return [self titleHeight];
    }
    
    return width / scale + [self titleHeight];
}

+ (CGFloat)titleHeight {
    return 30;
}
@end
