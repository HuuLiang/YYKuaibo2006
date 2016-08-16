//
//  YYKMineVIPCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKMineVIPCell.h"

@interface YYKMineVIPCell ()
{
    UILabel *_titleLabel;
    UIButton *_vipButton;
}
@end

@implementation YYKMineVIPCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_background"]];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        backgroundImageView.clipsToBounds = YES;
        [self addSubview:backgroundImageView];
        {
            [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        UIImageView *vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_vip_icon"]];
        vipImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:vipImageView];
        {
            [vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).multipliedBy(0.8);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#ffeb0d"];
        _titleLabel.font = kExExExBigFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [vipImageView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(vipImageView);
                make.centerY.equalTo(vipImageView).multipliedBy(1.1);
                make.size.equalTo(vipImageView).multipliedBy(0.75);
            }];
        }
        
        _vipButton = [[UIButton alloc] init];
        _vipButton.userInteractionEnabled = NO;
        _vipButton.layer.cornerRadius = 5;
        _vipButton.backgroundColor = [UIColor colorWithHexString:@"#ffeb0d"];
        [_vipButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [self addSubview:_vipButton];
        {
            [_vipButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(vipImageView.mas_bottom).offset(kTopBottomContentMarginSpacing);
                make.width.equalTo(vipImageView).multipliedBy(1.25);
                make.height.equalTo(self).multipliedBy(0.2);
            }];
        }
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setActionName:(NSString *)actionName {
    _actionName = actionName;
    [_vipButton setTitle:actionName forState:UIControlStateNormal];
}
@end
