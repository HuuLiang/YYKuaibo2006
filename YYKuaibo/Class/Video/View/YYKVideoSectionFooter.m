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
}
@end

@implementation YYKVideoSectionFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _titleLabel.font = kMediumFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
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
@end
