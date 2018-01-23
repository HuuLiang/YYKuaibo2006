//
//  YYKVideoCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoCell.h"

@interface YYKVideoCell ()
{
    UIView *_footerView;
    UILabel *_titleLabel;
    UIImageView *_coverImageView;
    UILabel *_tagLabel;
    UILabel *_popLabel;
}
@end

@implementation YYKVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _footerView = [[UIView alloc] init];
        [self addSubview:_footerView];
        {
            [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.height.mas_equalTo([[self class] titleHeight]);
            }];
        }

        _popLabel = [[UILabel alloc] init];
        _popLabel.textColor = kDefaultLightTextColor;
        _popLabel.font = kExtraSmallFont;
        _popLabel.textAlignment = NSTextAlignmentCenter;
        [_footerView addSubview:_popLabel];
        {
            [_popLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_footerView).offset(5);
                make.bottom.equalTo(_footerView).offset(-kMediumVerticalSpacing);
                make.right.equalTo(_footerView).offset(-5);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kSmallFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kDefaultTextColor;
        [_footerView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_popLabel);
                make.bottom.equalTo(_popLabel.mas_top).offset(-kSmallVerticalSpacing);
            }];
        }

        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];
        {
            [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.bottom.equalTo(_footerView.mas_top);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setPopularity:(NSUInteger)popularity {
    _popularity = popularity;
    _popLabel.text = [NSString stringWithFormat:@"%ld人观看", (unsigned long)popularity];
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_coverImageView sd_setImageWithURL:imageURL placeholderImage:self.placeholderImage];
}

- (void)setTagText:(NSString *)tagText {
    if (tagText.length > 2) {
        tagText = [tagText substringToIndex:2];
    }
    _tagText = tagText;
    
    if (tagText.length > 0 && !_tagLabel) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = kExtraSmallFont;
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.backgroundColor = self.tagBackgroundColor;
        _tagLabel.layer.masksToBounds = YES;
        [_tagLabel aspect_hookSelector:@selector(layoutSubviews) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo)
        {
            UILabel *thisLabel = [aspectInfo instance];
            thisLabel.layer.cornerRadius = CGRectGetWidth(thisLabel.frame)/2;
        } error:nil];
        [self addSubview:_tagLabel];
        {
            const CGSize tagSize = CGSizeMake(30, 30);
            [_tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.centerY.equalTo(_coverImageView.mas_bottom).offset(-tagSize.height/4);
                make.size.mas_equalTo(tagSize);
            }];
        }
    }

    _tagLabel.hidden = tagText.length == 0;
    _tagLabel.text = tagText;

}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor {
    _tagBackgroundColor = tagBackgroundColor;
    
    _tagLabel.backgroundColor = tagBackgroundColor;
}

+ (CGFloat)heightRelativeToWidth:(CGFloat)width withScale:(CGFloat)scale {
    if (scale == 0) {
        return [self titleHeight];
    }
    
    return width / scale + [self titleHeight];
}

+ (CGFloat)titleHeight {
    return 50;
}
@end
