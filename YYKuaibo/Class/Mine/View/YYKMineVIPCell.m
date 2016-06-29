//
//  YYKMineVIPCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKMineVIPCell.h"

@interface YYKMineVIPCell ()
{
    UIView *_memberView;
    UILabel *_titleLabel;
}
@end

@implementation YYKMineVIPCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _memberView = [[UIView alloc] init];
        _memberView.backgroundColor = kThemeColor;
        _memberView.clipsToBounds = YES;
        [_memberView aspect_hookSelector:@selector(layoutSubviews)
                             withOptions:AspectPositionAfter
                              usingBlock:^(id<AspectInfo> aspectInfo)
        {
            UIView *thisView = [aspectInfo instance];
            thisView.layer.cornerRadius = CGRectGetHeight(thisView.frame)/2;
        } error:nil];
        [self addSubview:_memberView];
        {
            [_memberView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.height.equalTo(self).multipliedBy(0.8);
                make.width.equalTo(_memberView.mas_height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16.];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_memberView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(_memberView);
            }];
        }
//        _vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_text"]];
//        [self addSubview:_vipImageView];
//        {
//            [_vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self);
//                make.top.equalTo(self).offset(30);
//                make.size.mas_equalTo(_vipImageView.image.size);
//            }];
//        }
        
//        _promptLabel = [[UILabel alloc] init];
//        _promptLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
//        _promptLabel.text = @"成为会员，马上免费观看所有视频";
//        _promptLabel.font = [UIFont systemFontOfSize:18.];
//        [self addSubview:_promptLabel];
//        {
//            [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self);
//                make.top.equalTo(_vipImageView.mas_bottom).offset(10);
//            }];
//        }
        
//        _memberButton = [[UIButton alloc] init];
//        _memberButton.titleLabel.font = [UIFont systemFontOfSize:18.];
//        _memberButton.layer.cornerRadius = 4;
//        _memberButton.layer.masksToBounds = YES;
//        [_memberButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#fa1e67"]] forState:UIControlStateNormal];
//        [_memberButton setTitle:@"成为会员" forState:UIControlStateNormal];
//        [_memberButton bk_addEventHandler:^(id sender) {
//            @strongify(self);
//            if (self.memberAction) {
//                self.memberAction(self);
//            }
//        } forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_memberButton];
//        {
//            [_memberButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self);
//                make.top.equalTo(_vipImageView.mas_bottom).offset(15);
//                make.width.equalTo(self).multipliedBy(0.5);
//                make.height.mas_equalTo(44);
//            }];
//        }
    }
    return self;
}

- (void)setMemberTitle:(NSString *)memberTitle {
    _memberTitle = memberTitle;
    _titleLabel.text = memberTitle;
}

//- (void)setVipImage:(UIImage *)vipImage {
//    _vipImage = vipImage;
//    _vipImageView.image = vipImage;
//}
//
//- (void)setMemberTitle:(NSString *)memberTitle {
//    _memberTitle = memberTitle;
//    [_memberButton setTitle:memberTitle forState:UIControlStateNormal];
//}
@end
