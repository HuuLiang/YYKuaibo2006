//
//  YYKSpreadCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSpreadCell.h"

@interface YYKSpreadCell ()
{
    UIImageView *_thumbImageView;
//    UILabel *_titleLabel;
}
@property (nonatomic,retain) UIView *installedView;
@end

@implementation YYKSpreadCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
//        _thumbImageView.layer.cornerRadius = 18;
//        _thumbImageView.layer.masksToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
//        _titleLabel = [[UILabel alloc] init];
//        _titleLabel.font = [UIFont systemFontOfSize:16.];
//        _titleLabel.textColor = [UIColor whiteColor];
//        _titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:_titleLabel];
//        {
//            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(_thumbImageView.mas_bottom).offset(5);
//                make.left.right.bottom.equalTo(self);
//            }];
//        }
    }
    return self;
}

- (UIView *)installedView {
    if (_installedView) {
        return _installedView;
    }
    
    _installedView = [[UIView alloc] init];
    _installedView.hidden = YES;
    _installedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_thumbImageView addSubview:_installedView];
    {
        [_installedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_thumbImageView);
        }];
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"已安装";
    label.font = [UIFont systemFontOfSize:20.];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [_installedView addSubview:label];
    {
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_installedView);
        }];
    }
    return _installedView;
}

//- (void)setTitle:(NSString *)title {
//    _title = title;
//    _titleLabel.text = title;
//}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:self.placeholderImage];
}

- (void)setIsInstalled:(BOOL)isInstalled {
    _isInstalled = isInstalled;
    
    if (isInstalled) {
        self.installedView.hidden = NO;
    } else {
        _installedView.hidden = YES;
    }
}
@end
