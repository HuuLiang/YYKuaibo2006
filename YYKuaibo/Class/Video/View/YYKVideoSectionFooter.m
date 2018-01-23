//
//  YYKVideoSectionFooter.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoSectionFooter.h"

@interface YYKVideoSectionFooter ()
{
    UILabel *_titleLabel;
    UIView *_separatorView;
}
@end

@implementation YYKVideoSectionFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _showSeparator = YES;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kDefaultTextColor;
        _titleLabel.font = kMediumFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
        }
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = kDefaultTextColor;
        [self addSubview:_separatorView];
        {
            [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self);
                make.height.mas_equalTo(0.5);
            }];
        }
        
        @weakify(self);
        [self bk_whenTapped:^{
            @strongify(self);
            SafelyCallBlock(self.tapAction, self);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setShowSeparator:(BOOL)showSeparator {
    _showSeparator = showSeparator;
    
    _separatorView.hidden = !showSeparator;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    
    if (!titleColor) {
        titleColor = [UIColor colorWithHexString:@"#333333"];
    }
    _titleLabel.textColor = titleColor;
}
@end
