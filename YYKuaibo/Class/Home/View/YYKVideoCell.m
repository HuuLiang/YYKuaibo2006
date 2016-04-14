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
}
@end

@implementation YYKVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _coverImageView = [[UIImageView alloc] init];
        [self addSubview:_coverImageView];
        {
            [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self addSubview:_footerView];
        {
            [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.height.mas_equalTo([[self class] footerHeight]);
            }];
        }

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15.];
        _titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        [_footerView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_footerView).offset(5);
                make.centerY.equalTo(_footerView);
                make.right.equalTo(_footerView).offset(-5);
            }];
        }
    }
    return self;
}

+ (CGFloat)footerHeight {
    return 30;
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
    [_coverImageView sd_setImageWithURL:imageURL];
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
                make.left.equalTo(_footerView).offset([[self class] footerHeight]*iconHeightScale + 10);
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
@end
