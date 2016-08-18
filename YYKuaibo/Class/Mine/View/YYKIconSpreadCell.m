//
//  YYKIconSpreadCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKIconSpreadCell.h"

@interface YYKIconSpreadCell ()
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
}
@end

@implementation YYKIconSpreadCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.layer.cornerRadius = 15;
        _iconImageView.clipsToBounds = YES;
        [self addSubview:_iconImageView];
        {
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.height.mas_equalTo(_iconImageView.mas_width);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kBigFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
                make.top.equalTo(_iconImageView.mas_bottom);
                make.centerX.equalTo(self);
                make.width.equalTo(self).multipliedBy(1.2);
            }];
        }
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_iconImageView sd_setImageWithURL:imageURL placeholderImage:self.placeholderImage];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}
@end
