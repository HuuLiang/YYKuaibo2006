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
//@property (nonatomic,retain) UILabel *priceLabel;
//@property (nonatomic,retain) UILabel *originalPriceLabel;
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
//
//        _priceLabel = [[UILabel alloc] init];
//        _priceLabel.textColor = [UIColor redColor];
//        _priceLabel.font = [UIFont systemFontOfSize:16.];
//        [self addSubview:_priceLabel];
//        {
//            [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(self).offset(-10);
//                make.centerY.equalTo(self).offset(-5);
//            }];
//        }
//        
//        _originalPriceLabel = [[UILabel alloc] init];
//        _originalPriceLabel.textColor = [UIColor grayColor];
//        _originalPriceLabel.font = [UIFont systemFontOfSize:12.];
//        [self addSubview:_originalPriceLabel];
//        {
//            [_originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(_priceLabel);
//                make.top.equalTo(_priceLabel.mas_bottom).offset(1);
//            }];
//        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kBigFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_selectImageView.mas_right).offset(15);
                //make.right.equalTo(_priceLabel.mas_left).offset(-5).priority(MASLayoutPriorityFittingSizeLevel);
                make.centerY.equalTo(self);
                //make.bottom.equalTo(self.mas_centerY);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = kSmallFont;
        [self addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-15);
                make.left.equalTo(_titleLabel.mas_right).offset(15).priority(MASLayoutPriorityFittingSizeLevel);
                make.centerY.equalTo(self);
//                make.left.right.equalTo(_titleLabel);
//                make.top.equalTo(_titleLabel.mas_bottom).offset(lround(kScreenWidth*0.01));
            }];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    _selectImageView.image = selected ? [UIImage imageNamed:@"vip_type_selected_icon"] : [UIImage imageNamed:@"vip_type_normal_icon"];
    
    _titleLabel.textColor = selected ? [UIColor blackColor] : [UIColor colorWithWhite:0.75 alpha:1];
//    _priceLabel.textColor = selected ? [UIColor redColor] : [UIColor colorWithWhite:0.75 alpha:1];
//    _originalPriceLabel.textColor = selected ? [UIColor grayColor] : [UIColor colorWithWhite:0.75 alpha:1];
    _subtitleLabel.textColor = selected ? [UIColor grayColor] : [UIColor colorWithWhite:0.75 alpha:1];
}

//- (void)setCurrentPrice:(CGFloat)currentPrice {
//    _currentPrice = currentPrice;
//    
//    _priceLabel.text = [NSString stringWithFormat:@"仅需：¥%@", YYKIntegralPrice(currentPrice)];
//}
//
//- (void)setOriginalPrice:(CGFloat)originalPrice {
//    _originalPrice = originalPrice;
//    _originalPriceLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"原价：¥%@", YYKIntegralPrice(originalPrice)]
//                                                                         attributes:@{NSStrikethroughStyleAttributeName:@1}];
//}

- (void)setShowOnlyTitle:(BOOL)showOnlyTitle {
    _showOnlyTitle = showOnlyTitle;
    
    _titleLabel.hidden = showOnlyTitle;
    _selectImageView.hidden = showOnlyTitle;
    _subtitleLabel.hidden = showOnlyTitle;
//    _priceLabel.hidden = showOnlyTitle;
//    _originalPriceLabel.hidden = showOnlyTitle;
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
    _placeholderLabel.font = kMediumFont;
    _placeholderLabel.numberOfLines = 2;
    _placeholderLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_placeholderLabel];
    {
        [_placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
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
