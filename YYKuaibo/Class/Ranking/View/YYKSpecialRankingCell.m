//
//  YYKSpecialRankingCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSpecialRankingCell.h"

@interface YYKSpecialRankingCell ()
{
    UIImageView *_thumbImageView;
    UIView *_footerView;
    UILabel *_titleLabel;
}
@end

@implementation YYKSpecialRankingCell

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
        
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _footerView.hidden = YES;
        [self addSubview:_footerView];
        {
            [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.height.mas_equalTo(30);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = kBigFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_footerView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_footerView).offset(kLeftRightContentMarginSpacing);
                make.right.equalTo(_footerView).offset(-kLeftRightContentMarginSpacing);
                make.centerY.equalTo(_footerView);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    _footerView.hidden = title.length == 0;
    _titleLabel.text = title;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL];
}
@end
