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
    UIImageView *_backgroundImageView;
    UIImageView *_thumbImageView;
    
//    UIView *_bottomView;
//    UILabel *_titleLabel;
//    UILabel *_subtitleLabel;
    UIImageView *_vipIconImageView;
}
@end

@implementation YYKCard

- (instancetype)init {
    self = [super init];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        _thumbImageView.layer.cornerRadius = 5;
        [_thumbImageView YPB_addAnimationForImageAppearing];
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self).insets([[self class] imageInsets]);
            }];
        }

        _vipIconImageView = [[UIImageView alloc] init];
        _vipIconImageView.contentMode = UIViewContentModeCenter;
        [_thumbImageView addSubview:_vipIconImageView];
        {
            [_vipIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_thumbImageView).offset(15);
                make.top.equalTo(_thumbImageView).offset(15);
                make.size.mas_equalTo(CGSizeMake(44, 44));
            }];
        }
        
//        _bottomView = [[UIView alloc] init];
//        [self addSubview:_bottomView];
//        {
//            [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.equalTo(_thumbImageView);
//                make.top.equalTo(_thumbImageView.mas_bottom).offset(kInnerInsets);
//                make.bottom.equalTo(self).offset(-kInnerInsets);
//            }];
//        }

//        _titleLabel = [[UILabel alloc] init];
//        _titleLabel.font = [UIFont systemFontOfSize:MIN(kScreenHeight/30.,20)];
//        [_bottomView addSubview:_titleLabel];
//        {
//            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(_bottomView);
//                make.right.equalTo(_bottomView).offset(-5);
//                make.bottom.equalTo(_bottomView.mas_centerY);
//            }];
//        }
//        
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
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    
    if (backgroundImage && !_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
        [self insertSubview:_backgroundImageView atIndex:0];
        {
            [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
    
    _backgroundImageView.image = backgroundImage;
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    _vipIconImageView.image = iconImage;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    @weakify(self);
    [_thumbImageView sd_setImageWithURL:imageURL
                       placeholderImage:self.placeholderImage
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        @strongify(self);
        _vipIconImageView.image = image ? self.iconImage : nil;
    }];
}

+ (UIEdgeInsets)imageInsets {
    return UIEdgeInsetsMake(0, 0, 8, 0);
}

+ (CGSize)sizeRelativeToWidth:(CGFloat)width imageScale:(CGFloat)imageScale {
    const UIEdgeInsets imageInsets = [self imageInsets];
    const CGFloat imageWidth = width - imageInsets.left - imageInsets.right;
    const CGFloat imageHeight = imageScale == 0 ? 0 : imageWidth/imageScale;
    return imageHeight == 0 ? CGSizeZero : CGSizeMake(width, imageHeight+imageInsets.top+imageInsets.bottom);
}
//- (void)setTitle:(NSString *)title {
//    _title = title;
//    _titleLabel.text = title;
//}
//
//- (void)setSubtitle:(NSString *)subtitle {
//    _subtitle = subtitle;
//    
//    _subtitleLabel.text = subtitle;
//    _subtitleLabel.hidden = subtitle.length == 0;
//}
@end
