//
//  YYKCategoryPlainTextCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCategoryPlainTextCell.h"

@interface YYKCategoryPlainTextCell ()
{
    UILabel *_titleLabel;
}
@end

@implementation YYKCategoryPlainTextCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kDefaultTextColor;
        _titleLabel.font = kMediumFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setIsSpecial:(BOOL)isSpecial {
    _isSpecial = isSpecial;
    
    if (isSpecial) {
        _titleLabel.textColor = [UIColor colorWithHexString:@"#de2966"];
    } else {
        _titleLabel.textColor = kDefaultTextColor;
    }
}

@end
