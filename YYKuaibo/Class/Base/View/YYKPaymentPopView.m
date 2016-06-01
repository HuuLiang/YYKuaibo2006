//
//  YYKPaymentPopView.m
//  JQKuaibo
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "YYKPaymentPopView.h"
#import "YYKPaymentButton.h"
#import "YYKPayPointTypeCell.h"
#import "YYKSystemConfigModel.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, YYKPaymentPopViewSection) {
    HeaderImageSection,
    TitleSection,
    PayPointTypeSection,
    PaymentTypeSection,
    SectionCount
};

static const CGFloat kHeaderImageScale = 1037./680.;
static const CGFloat kFooterImageScale = 519./32.;
static NSString *const kPayPointTypeCellReusableIdentifier = @"PayPointTypeCellReusableIdentifier";

#define kTitleCellHeight MIN(kScreenHeight * 0.08, 50)
#define kPaymentCellHeight MIN(kScreenHeight * 0.15, 60)
#define kPayPointTypeCellHeight MIN(kScreenHeight * 0.1, 60)
#define kReservedCellHeight (kScreenHeight * 0.03)

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
        self.separatorColor = [UIColor colorWithWhite:0.2 alpha:1];
        self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
        self.separatorColor = [UIColor lightGrayColor];
        [self registerClass:[YYKPayPointTypeCell class] forCellReuseIdentifier:kPayPointTypeCellReusableIdentifier];
    }
    return self;
}

- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width {
    const CGFloat headerImageHeight = width / kHeaderImageScale;
//    const CGFloat titleImageHeight = kTitleCellHeight;
//    
//    __block CGFloat cellHeights = headerImageHeight+titleImageHeight;
//    [self.cells enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * _Nonnull key, UITableViewCell * _Nonnull obj, BOOL * _Nonnull stop) {
//        cellHeights += [self tableView:self heightForRowAtIndexPath:key];
//    }];
//
    __block CGFloat cellHeights = headerImageHeight;
    NSUInteger numberOfSections = [self numberOfSections];
    for (NSUInteger section = 1; section < numberOfSections; ++section) {
        NSUInteger numberOfItems = [self tableView:self numberOfRowsInSection:section];
        for (NSUInteger item = 0; item < numberOfItems; ++item) {
            CGFloat itemHeight = [self tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:item inSection:section]];
            cellHeights += itemHeight;
        }
    }
    cellHeights += kReservedCellHeight;
//    cellHeights += [self tableView:self heightForHeaderInSection:1];
    return lround(cellHeights);
}

- (void)addPaymentWithImage:(UIImage *)image
                      title:(NSString *)title
            backgroundColor:(UIColor *)backgroundColor
                     action:(YYKAction)action
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.cells.count inSection:PaymentTypeSection];
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
    
    [self.cells setObject:cell forKey:indexPath];
}

- (void)setHeaderImageURL:(NSURL *)headerImageURL {
    _headerImageURL = headerImageURL;
    [_headerImageView sd_setImageWithURL:headerImageURL placeholderImage:[UIImage imageNamed:@"payment_header_placeholder"] options:SDWebImageDelayPlaceholder];
}

- (void)setPayPointType:(YYKPayPointType)payPointType {
    _payPointType = payPointType;
    self.headerImageURL = [NSURL URLWithString:[[YYKSystemConfigModel sharedModel] paymentImageWithPayPointType:payPointType]];
//    [self reloadSections:[NSIndexSet indexSetWithIndex:PayPointTypeSection] withRowAnimation:UITableViewRowAnimationNone];
    [self selectRowAtIndexPath:[NSIndexPath indexPathForRow:payPointType==YYKPayPointTypeSVIP?1:0 inSection:PayPointTypeSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HeaderImageSection) {
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
    } else if (indexPath.section == TitleSection) {
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
    } else if (indexPath.section == PayPointTypeSection) {
        YYKPayPointTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayPointTypeCellReusableIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL isUpgrade = [YYKUtil isVIP] && ![YYKUtil isSVIP];
        if (indexPath.row == 0) {
            cell.showOnlyTitle = isUpgrade;
            cell.userInteractionEnabled = !isUpgrade;
            if (isUpgrade) {
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"亲，您是普通VIP会员\n不能观看黑钻VIP区的视频哦~~~" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
                [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(4, 7)];
                cell.placeholder = attrString;
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.titleLabel.text = @"普通VIP";
                cell.subtitleLabel.text = @"可观看除黑钻区的所有视频";
                cell.currentPrice = [[YYKSystemConfigModel sharedModel] paymentPriceWithPayPointType:YYKPayPointTypeVIP] / 100.;
                cell.originalPrice = [YYKSystemConfigModel sharedModel].originalPayAmount / 100.;
            }
        } else {
            cell.userInteractionEnabled = YES;
            cell.titleLabel.text = isUpgrade ? @"升级成为黑钻VIP" : @"黑钻VIP";
            cell.subtitleLabel.text = @"可观看所有视频";
            cell.currentPrice = [[YYKSystemConfigModel sharedModel] paymentPriceWithPayPointType:YYKPayPointTypeSVIP] / 100.;
            cell.originalPrice = [YYKSystemConfigModel sharedModel].originalSVIPPayAmount / 100.;
            cell.titleLabel.textColor = [UIColor redColor];
            cell.showOnlyTitle = NO;
        }
        return cell;
    } else {
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        return self.cells[cellIndexPath];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == PayPointTypeSection) {
        return 2;
    } else if (section == PaymentTypeSection) {
        return self.cells.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HeaderImageSection) {
        return CGRectGetWidth(tableView.bounds) / kHeaderImageScale;
    } else if (indexPath.section == TitleSection) {
        return kTitleCellHeight;
    } else if (indexPath.section == PayPointTypeSection) {
        return kPayPointTypeCellHeight;
    } else {
        return kPaymentCellHeight;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    UITableViewCell *cell = self.cells[cellIndexPath];
    if (cell) {
        UIButton *paymentButton = objc_getAssociatedObject(cell, kPaymentButtonAssociatedKey);
        paymentButton.highlighted = YES;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PayPointTypeSection) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    UITableViewCell *cell = self.cells[cellIndexPath];
    if (cell) {
        UIButton *paymentButton = objc_getAssociatedObject(cell, kPaymentButtonAssociatedKey);
        paymentButton.highlighted = NO;
        [paymentButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else if (indexPath.section == PayPointTypeSection) {
        self.payPointType = indexPath.row == 1 ? YYKPayPointTypeSVIP : YYKPayPointTypeVIP;   
    }
}

//- (BOOL)tableView:(UITableView *)tableView hasBorderInSection:(NSUInteger)section {
//    return section == PayPointTypeSection;
//}

- (BOOL)tableView:(UITableView *)tableView hasSeparatorBetweenIndexPath:(NSIndexPath *)lowerIndexPath andIndexPath:(NSIndexPath *)upperIndexPath {
    return lowerIndexPath.section == PayPointTypeSection;
}
@end
