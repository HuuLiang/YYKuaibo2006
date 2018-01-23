//
//  YYKChannelCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelCell.h"

typedef NS_ENUM(NSUInteger, SeparatorPosition) {
    SeparatorPositionBottom,
    SeparatorPositionLeft,
    SeparatorPositionRight,
    SeparatorPositionTopLeft,
    SeparatorPositionTopRight,
    NumberOfSeparators
};

@interface YYKChannelCell ()
{
    UIImageView *_thumbImageView;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    UILabel *_popLabel;
}
@property (nonatomic,retain) NSMutableDictionary<NSNumber *, UIView *> *titleSeparators;
@end

@implementation YYKChannelCell

DefineLazyPropertyInitialization(NSMutableDictionary, titleSeparators)

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = kExtraExtraBigFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
        }
        
        _popLabel = [[UILabel alloc] init];
        _popLabel.textColor = [UIColor whiteColor];
        _popLabel.font = kSmallFont;
        [self addSubview:_popLabel];
        {
            [_popLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(_titleLabel.mas_top);//.offset(-kSmallVerticalSpacing);
            }];
        }
        
        for (NSUInteger i = 0; i < NumberOfSeparators; ++i) {
            UIView *separatorView = [[UIView alloc] init];
            separatorView.backgroundColor = [UIColor whiteColor];
            [self addSubview:separatorView];
            
            [self.titleSeparators setObject:separatorView forKey:@(i)];
        }
        
        [self.titleSeparators[@(SeparatorPositionBottom)] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(5);
            make.width.equalTo(_titleLabel).offset(15);
            make.height.mas_equalTo(1);
            make.centerX.equalTo(_titleLabel);
        }];
        
        [self.titleSeparators[@(SeparatorPositionTopLeft)] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_popLabel);
            make.right.equalTo(_popLabel.mas_left).offset(-kSmallHorizontalSpacing);
            make.left.equalTo(self.titleSeparators[@(SeparatorPositionBottom)]);
            make.height.mas_equalTo(1);
        }];
        
        [self.titleSeparators[@(SeparatorPositionTopRight)] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_popLabel);
            make.height.mas_equalTo(1);
            make.right.equalTo(self.titleSeparators[@(SeparatorPositionBottom)]);
            make.left.equalTo(_popLabel.mas_right).offset(kSmallHorizontalSpacing);
        }];
        
        [self.titleSeparators[@(SeparatorPositionLeft)] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1);
            make.top.equalTo(self.titleSeparators[@(SeparatorPositionTopLeft)]);
            make.right.equalTo(self.titleSeparators[@(SeparatorPositionBottom)].mas_left);
            make.bottom.equalTo(self.titleSeparators[@(SeparatorPositionBottom)]);
        }];
        
        [self.titleSeparators[@(SeparatorPositionRight)] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1);
            make.top.equalTo(self.titleSeparators[@(SeparatorPositionTopRight)]);
            make.left.equalTo(self.titleSeparators[@(SeparatorPositionTopRight)].mas_right);
            make.bottom.equalTo(self.titleSeparators[@(SeparatorPositionBottom)]);
        }];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.clipsToBounds = YES;
        _subtitleLabel.font = kSmallFont;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_subtitleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize subtitleSize = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:_subtitleLabel.font}];
    
    const CGFloat subtitleY = self.bounds.size.height * 0.7;
    const CGFloat width = subtitleSize.width + 15;
    const CGFloat height = subtitleSize.height + 10;
    const CGFloat subtitleX = (self.bounds.size.width - width)/2;
    _subtitleLabel.frame = CGRectMake(subtitleX, subtitleY, width, height);
    _subtitleLabel.layer.cornerRadius = height * 0.2;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleLabel.text = subtitle;
    
    [self setNeedsLayout];
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL placeholderImage:self.placeholderImage];
}

- (void)setPopularity:(NSUInteger)popularity {
    _popularity = popularity;
    _popLabel.text = [NSString stringWithFormat:@"%ld人在观看", (unsigned long)popularity];
}
@end
