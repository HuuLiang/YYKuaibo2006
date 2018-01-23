//
//  YYKCategoryHeaderView.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCategoryHeaderView.h"

@interface YYKCategoryHeaderView ()
{
    UIView *_contentView;
    UILabel *_titleLabel;
}
@end

@implementation YYKCategoryHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleOffset = 15;
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, frame.size.height-15)];
        [self addSubview:_contentView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleOffset, 0, _contentView.frame.size.width-_titleOffset*2, _contentView.frame.size.height)];
        _titleLabel.font = kBigFont;
        _titleLabel.textColor = kDefaultTextColor;
        [_contentView addSubview:_titleLabel];
//        {
//            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(_contentView).offset(15);
//                make.right.equalTo(_contentView).offset(-15);
//                make.centerY.equalTo(_contentView);
//            }];
//        }
    }
    return self;
}

- (void)setTitleOffset:(CGFloat)titleOffset {
    _titleOffset = titleOffset;
    _titleLabel.frame = CGRectMake(_titleOffset, 0, _contentView.frame.size.width-_titleOffset*2, _contentView.frame.size.height);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _contentView.backgroundColor = backgroundColor;
}

@end
