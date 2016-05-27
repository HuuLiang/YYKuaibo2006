//
//  YYKPaymentPopView.m
//  JQKuaibo
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "YYKPaymentPopView.h"
#import "YYKPaymentButton.h"
#import <objc/runtime.h>

static const CGFloat kHeaderImageScale = 1037./680.;
static const CGFloat kFooterImageScale = 519./32.;

#define kTitleCellHeight MIN(kScreenHeight * 0.08, 50)
#define kNormalCellHeight MIN(kScreenHeight * 0.15, 70)
#define kReservedCellHeight (kScreenHeight * 0.05)

static const void *kPaymentButtonAssociatedKey = &kPaymentButtonAssociatedKey;

@interface YYKPaymentPopView () <UITableViewDataSource,UITableViewSeparatorDelegate>
{
    UITableViewCell *_headerCell;
    UITableViewCell *_titleCell;
    
    UIImageView *_headerImageView;
    UIImageView *_titleImageView;
    UILabel *_priceLabel;
}
@property (nonatomic,retain) NSMutableDictionary<NSIndexPath *, UITableViewCell *> *cells;
@end

@implementation YYKPaymentPopView

DefineLazyPropertyInitialization(NSMutableDictionary, cells)

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        self.layer.cornerRadius = lround(kScreenWidth*0.08);
        self.layer.masksToBounds = YES;
//        self.hasRowSeparator = YES;
//        self.hasSectionBorder = YES;
        self.separatorColor = [UIColor colorWithWhite:0.2 alpha:1];
        self.priceColor = [UIColor redColor];
        self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    }
    return self;
}

- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width {
    const CGFloat headerImageHeight = width / kHeaderImageScale;
    const CGFloat titleImageHeight = kTitleCellHeight;
    
    __block CGFloat cellHeights = headerImageHeight+titleImageHeight;
    [self.cells enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * _Nonnull key, UITableViewCell * _Nonnull obj, BOOL * _Nonnull stop) {
        cellHeights += [self tableView:self heightForRowAtIndexPath:key];
    }];
    
    cellHeights += kReservedCellHeight;
//    cellHeights += [self tableView:self heightForHeaderInSection:1];
    return cellHeights;
}

- (void)addPaymentWithImage:(UIImage *)image
                      title:(NSString *)title
            backgroundColor:(UIColor *)backgroundColor
                     action:(YYKAction)action
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.cells.count inSection:2];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = self.backgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"payment_item_background"]];
//    [cell addSubview:backgroundView];
//    {
//        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(cell).insets(UIEdgeInsetsMake(5, 10, 5, 10));
//        }];
//    }
    YYKPaymentButton *paymentButton = [[YYKPaymentButton alloc] init];
    [paymentButton setTitle:title forState:UIControlStateNormal];
    [paymentButton setBackgroundImage:[UIImage imageWithColor:backgroundColor] forState:UIControlStateNormal];
    [paymentButton setImage:image forState:UIControlStateNormal];
    objc_setAssociatedObject(cell, kPaymentButtonAssociatedKey, paymentButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [cell addSubview:paymentButton];
    {
        [paymentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(cell);
            make.height.equalTo(cell).multipliedBy(0.7);
            make.width.equalTo(cell).multipliedBy(0.85);
        }];
    }
    
    [paymentButton bk_addEventHandler:^(id sender) {
        if (action) {
            action(sender);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    [cell addSubview:imageView];
//    {
//        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(cell);
//            make.left.equalTo(cell).offset(10);
//            make.height.equalTo(cell).multipliedBy(0.7);
//            make.width.equalTo(imageView.mas_height);
//        }];
//    }
//    
//    UIButton *button;
//    if (available) {
//        button = [[UIButton alloc] init];
//        objc_setAssociatedObject(cell, kPaymentButtonAssociatedKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        
//        UIImage *image = [UIImage imageNamed:@"payment_normal_button"];
//        [button setBackgroundImage:image forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"payment_highlight_button"] forState:UIControlStateHighlighted];
//        [cell addSubview:button];
//        {
//            [button mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerY.right.height.equalTo(cell);
//                make.width.equalTo(button.mas_height).multipliedBy(image.size.width/image.size.height);
//            }];
//        }
//        [button bk_addEventHandler:^(id sender) {
//            if (action) {
//                action(sender);
//            }
//        } forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    UILabel *titleLabel = [[UILabel alloc] init];
//    titleLabel.font = [UIFont boldSystemFontOfSize:lround(kScreenWidth*0.048)];
//    titleLabel.text = title;
//    titleLabel.textColor = [UIColor whiteColor];
//    [backgroundView addSubview:titleLabel];
//    {
//        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(imageView.mas_right).offset(10);
//            make.centerY.equalTo(backgroundView);
//            make.right.equalTo(button?button.mas_left:backgroundView);
//        }];
//    }
    
    [self.cells setObject:cell forKey:indexPath];
}

- (void)setHeaderImageURL:(NSURL *)headerImageURL {
    _headerImageURL = headerImageURL;
    [_headerImageView sd_setImageWithURL:headerImageURL placeholderImage:[UIImage imageNamed:@"payment_header_placeholder"] options:SDWebImageDelayPlaceholder];
}

- (void)setShowPrice:(NSNumber *)showPrice {
    _showPrice = showPrice;
    [self priceLabelShowPrice:showPrice];
}

- (void)priceLabelShowPrice:(NSNumber *)showPrice {
    if (showPrice == nil) {
        _priceLabel.text = nil;
        return ;
    }
    
    double price = showPrice.doubleValue;
    BOOL showInteger = (NSUInteger)(price * 100) % 100 == 0;
    _priceLabel.text = showInteger ? [NSString stringWithFormat:@"%ld", (unsigned long)price] : [NSString stringWithFormat:@"%.2f", price];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!_headerCell) {
            _headerCell = [[UITableViewCell alloc] init];
            _headerCell.backgroundColor = self.backgroundColor;
            _headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            _headerImageView = [[UIImageView alloc] init];
            [_headerImageView sd_setImageWithURL:_headerImageURL
                                placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"payment_header_placeholder" ofType:@"jpg"]]];
            [_headerCell addSubview:_headerImageView];
            {
                [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(_headerCell);
                }];
            }
            
            _priceLabel = [[UILabel alloc] init];
            _priceLabel.textColor = self.priceColor;
            _priceLabel.font = [UIFont boldSystemFontOfSize:MIN(20, kScreenWidth*0.05)];
            _priceLabel.textAlignment = NSTextAlignmentCenter;
            [self priceLabelShowPrice:_showPrice];
            [_headerImageView addSubview:_priceLabel];
            {
                [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.top.equalTo(_headerImageView.mas_centerY).multipliedBy(1.15);
                    make.centerY.equalTo(_headerImageView).multipliedBy(1.6);
                    make.centerX.equalTo(_headerImageView).multipliedBy(1.6);
                    make.width.equalTo(_headerImageView).multipliedBy(0.2);
                }];
            }
            
            UIButton *closeButton = [[UIButton alloc] init];
            closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
            [_headerCell addSubview:closeButton];
            {
                [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.right.equalTo(_headerCell);
                    make.size.mas_equalTo(CGSizeMake(50, 50));
                }];
            }
            
            @weakify(self);
            [closeButton bk_addEventHandler:^(id sender) {
                @strongify(self);
                if (self.closeAction) {
                    self.closeAction(sender);
                }
            } forControlEvents:UIControlEventTouchUpInside];
        }
        return _headerCell;
    } else if (indexPath.section == 1) {
        if (!_titleCell) {
            _titleCell = [[UITableViewCell alloc] init];
            _titleCell.backgroundColor = self.backgroundColor;
            _titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            _titleImageView = [[UIImageView alloc] initWithImage:_titleImage];
            [_titleCell addSubview:_titleImageView];
            {
                [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(_titleCell);
                    make.height.equalTo(_titleCell).multipliedBy(0.35);
                    make.width.equalTo(_titleImageView.mas_height).multipliedBy(kFooterImageScale);
                }];
            }
        }
        return _titleCell;
    } else {
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        return self.cells[cellIndexPath];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return self.cells.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGRectGetWidth(tableView.bounds) / kHeaderImageScale;
    } else if (indexPath.section == 1) {
        return kTitleCellHeight;
    } else {
        return kNormalCellHeight;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [[UIView alloc] init];
//    
//    UIImageView *paymentHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"payment_section"]];
//    [headerView addSubview:paymentHeader];
//    {
//        [paymentHeader mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(headerView);
//        }];
//    }
//    return headerView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        return 30;
//    }
//    return 0;
//}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    UITableViewCell *cell = self.cells[cellIndexPath];
    if (cell) {
        UIButton *paymentButton = objc_getAssociatedObject(cell, kPaymentButtonAssociatedKey);
        paymentButton.highlighted = YES;
    }
    return YES;
}

//- (BOOL)tableView:(UITableView *)tableView hasBorderInSection:(NSUInteger)section {
//    if (section == 2) {
//        return YES;
//    }
//    return NO;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    UITableViewCell *cell = self.cells[cellIndexPath];
    if (cell) {
        UIButton *paymentButton = objc_getAssociatedObject(cell, kPaymentButtonAssociatedKey);
        paymentButton.highlighted = NO;
        [paymentButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
@end
