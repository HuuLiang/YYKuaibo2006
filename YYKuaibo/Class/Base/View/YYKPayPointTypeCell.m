//
//  YYKPayPointTypeCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPayPointTypeCell.h"

@interface YYKPayPointTypeCell ()
@property (nonatomic,retain) UIImageView *selectImageView;
@property (nonatomic,retain) UILabel *priceLabel;
@property (nonatomic,retain) UILabel *originalPriceLabel;
@property (nonatomic,retain) UILabel *placeholderLabel;
@end

@implementation YYKPayPointTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_type_normal_icon"]];
        [self addSubview:_selectImageView];
        {
            [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(15);
                make.height.equalTo(self).multipliedBy(0.3);
                make.width.equalTo(_selectImageView.mas_height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18.];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_selectImageView.mas_right).offset(5);
                make.centerY.equalTo(self);
            }];
        }
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = [UIColor redColor];
        _priceLabel.font = [UIFont systemFontOfSize:16.];
        [self addSubview:_priceLabel];
        {
            [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-15);
                make.centerY.equalTo(self).offset(-5);
            }];
        }
        
        _originalPriceLabel = [[UILabel alloc] init];
        _originalPriceLabel.textColor = [UIColor grayColor];
        _originalPriceLabel.font = [UIFont systemFontOfSize:12.];
        [self addSubview:_originalPriceLabel];
        {
            [_originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_priceLabel);
                make.top.equalTo(_priceLabel.mas_bottom).offset(1);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:14.];

        [self addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel.mas_right).offset(5);
                make.right.equalTo(_priceLabel.mas_left).offset(-5).priority(MASLayoutPriorityFittingSizeLevel);
                make.centerY.equalTo(self);
            }];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    _selectImageView.image = selected ? [UIImage imageNamed:@"vip_type_selected_icon"] : [UIImage imageNamed:@"vip_type_normal_icon"];
}

- (void)setCurrentPrice:(CGFloat)currentPrice {
    _currentPrice = currentPrice;
    _priceLabel.text = [NSString stringWithFormat:@"¥ %.2f", currentPrice];
}

- (void)setOriginalPrice:(CGFloat)originalPrice {
    _originalPrice = originalPrice;
    _originalPriceLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥ %.2f", originalPrice]
                                                                         attributes:@{NSStrikethroughStyleAttributeName:@1}];
}

- (void)setShowOnlyTitle:(BOOL)showOnlyTitle {
    _showOnlyTitle = showOnlyTitle;
    
    _titleLabel.hidden = showOnlyTitle;
    _selectImageView.hidden = showOnlyTitle;
    _subtitleLabel.hidden = showOnlyTitle;
    _priceLabel.hidden = showOnlyTitle;
    _originalPriceLabel.hidden = showOnlyTitle;
    _placeholderLabel.hidden = !showOnlyTitle;
//    if (showOnlyTitle) {
//        [_priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_selectImageView.mas_right).offset(5);
//            make.centerY.equalTo(self);
//            make.right.equalTo(self).offset(-15);
//        }];
//    } else {
//        [_priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_selectImageView.mas_right).offset(5);
//            make.centerY.equalTo(self);
//        }];
//    }
}

- (UILabel *)placeholderLabel {
    if (_placeholderLabel) {
        return _placeholderLabel;
    }
    
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.font = [UIFont systemFontOfSize:16.];
    [self addSubview:_placeholderLabel];
    {
        [_placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
        }];
    }
    return _placeholderLabel;
}

- (void)setPlaceholder:(NSAttributedString *)placeholder {
    _placeholder = placeholder;
    
    if (placeholder) {
        self.placeholderLabel.attributedText = placeholder;
    } else {
        _placeholderLabel.hidden = YES;
    }
}
@end
