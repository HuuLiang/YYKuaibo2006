//
//  YYKMineMenuCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKMineMenuCell.h"

@interface YYKMineMenuCell ()
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
}
@end

@implementation YYKMineMenuCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#444444"];
        _titleLabel.font = kBigFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.bottom.equalTo(self).offset(-kMediumVerticalSpacing);
            }];
        }
        
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconImageView];
        {
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).offset(-_titleLabel.font.pointSize/2);
                make.height.equalTo(self).multipliedBy(0.4);
                make.width.equalTo(_iconImageView.mas_height);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    _iconImageView.image = iconImage;
}
@end
