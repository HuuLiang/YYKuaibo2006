//
//  YYKCategoryRectTextCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCategoryRectTextCell.h"

@interface YYKCategoryRectTextCell ()
{
    UILabel *_titleLabel;
}
@end

@implementation YYKCategoryRectTextCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = kDefaultTextColor.CGColor;
        self.layer.borderWidth = 1;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kBigFont;
        _titleLabel.textColor = kDefaultTextColor;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
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
        self.backgroundColor = [UIColor colorWithHexString:@"#83358e"];
        self.layer.borderWidth = 0;
        _titleLabel.textColor = [UIColor whiteColor];
    } else {
//        self.layer.borderColor = kCategoryTextColor.CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = kDefaultTextColor;
    }
}
@end
