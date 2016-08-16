//
//  YYKHomeTrialCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeTrialCell.h"

@interface YYKHomeTrialCell ()
{
    UIImageView *_thumbImageView;
    UILabel *_titleLabel;
}
@end

@implementation YYKHomeTrialCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [[self class] titleFont];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
                make.height.mas_equalTo([[self class] titleHeight]);
                make.left.equalTo(self).offset(kSmallHorizontalSpacing);
                make.right.equalTo(self).offset(-kSmallHorizontalSpacing);
            }];
        }
        
        _thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_1_1"]];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.bottom.equalTo(_titleLabel.mas_top);
            }];
        }
        
        
    }
    return self;
}

+ (UIFont *)titleFont {
    return kMediumFont;
}

+ (CGFloat)titleHeight {
    return [self titleFont].pointSize * 1.875;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder_1_1"]];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

+ (CGFloat)heightRelativeToWidth:(CGFloat)width withImageScale:(CGFloat)imageScale {
    if (imageScale == 0) {
        return [self titleHeight];
    } else {
        return width / imageScale + [self titleHeight];
    }
}
@end
