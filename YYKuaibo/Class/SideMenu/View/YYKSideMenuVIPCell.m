//
//  YYKSideMenuVIPCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSideMenuVIPCell.h"

@interface YYKSideMenuVIPCell ()
{
    UIButton *_backButton;
    UIImageView *_vipImageView;
    UILabel *_promptLabel;
    UIButton *_memberButton;
}
@end

@implementation YYKSideMenuVIPCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        @weakify(self);
        _backButton = [[UIButton alloc] init];
        _backButton.tintColor = [UIColor grayColor];
        UIImage *image = [[UIImage imageNamed:@"navigation_back_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_backButton setImage:image forState:UIControlStateNormal];
        [_backButton aspect_hookSelector:@selector(imageRectForContentRect:)
                             withOptions:AspectPositionInstead
                              usingBlock:^(id<AspectInfo> aspectInfo, CGRect contentRect)
        {
            CGRect imageRect = CGRectInset(contentRect, 10, 10);
            [[aspectInfo originalInvocation] setReturnValue:&imageRect];
        } error:nil];
        [_backButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.backAction) {
                self.backAction(self);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        {
            [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(20);
                make.top.equalTo(self).offset(15);
                make.size.mas_equalTo(CGSizeMake(30, 40));
            }];
        }

        _vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_text"]];
        [self addSubview:_vipImageView];
        {
            [_vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_backButton.mas_centerY);
            }];
        }
        
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.textColor = [UIColor grayColor];
        _promptLabel.text = @"成为会员，马上免费观看所有视频";
        _promptLabel.font = [UIFont systemFontOfSize:18.];
        [self addSubview:_promptLabel];
        {
            [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_vipImageView.mas_bottom).offset(10);
            }];
        }
        
        _memberButton = [[UIButton alloc] init];
        _memberButton.titleLabel.font = [UIFont systemFontOfSize:18.];
        _memberButton.layer.cornerRadius = 4;
        _memberButton.layer.masksToBounds = YES;
        [_memberButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#fa1e67"]] forState:UIControlStateNormal];
        [_memberButton setTitle:@"成为会员" forState:UIControlStateNormal];
        [_memberButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.memberAction) {
                self.memberAction(self);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_memberButton];
        {
            [_memberButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_promptLabel.mas_bottom).offset(10);
                make.width.equalTo(self).multipliedBy(0.4);
                make.height.mas_equalTo(44);
            }];
        }
    }
    return self;
}

@end
