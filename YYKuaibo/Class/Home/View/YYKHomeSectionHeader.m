//
//  YYKHomeSectionHeader.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeSectionHeader.h"

@interface YYKHomeSectionHeader ()
{
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}
@end

@implementation YYKHomeSectionHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = _titleLabel.textColor;
        _subtitleLabel.font = _titleLabel.font;
        [_contentView addSubview:_subtitleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_contentView).offset(15);
            make.centerY.equalTo(_contentView);
            make.right.equalTo(_subtitleLabel.mas_left).offset(-5).priority(MASLayoutPriorityRequired);
        }];
        
        [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_contentView).offset(-15);
            make.centerY.equalTo(_contentView);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
}

- (void)setContentSizeOffset:(UIOffset)contentSizeOffset {
    BOOL update = contentSizeOffset.horizontal != _contentSizeOffset.horizontal || contentSizeOffset.vertical != _contentSizeOffset.vertical;
    _contentSizeOffset = contentSizeOffset;
    
    if (update) {
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(self).sizeOffset(CGSizeMake(contentSizeOffset.horizontal, contentSizeOffset.vertical));
        }];
    }
}
@end
