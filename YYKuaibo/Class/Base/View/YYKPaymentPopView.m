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
//    TitleSection,
    PayPointTypeSection,
    PaymentTypeSection,
    SectionCount
};

static const CGFloat kHeaderImageScale = 545./557.;//400.;
static NSString *const kPayPointTypeCellReusableIdentifier = @"PayPointTypeCellReusableIdentifier";

#define kTitleCellHeight MIN(kScreenHeight * 0.08, 50)
#define kPaymentCellHeight MIN(kScreenHeight * 0.15, 60)
#define kPayPointTypeCellHeight MIN(kScreenHeight * 0.1, 60)
#define kFooterHeight (kScreenHeight * 0.06)

static const void *kPaymentButtonAssociatedKey = &kPaymentButtonAssociatedKey;

@interface YYKPaymentPopView () <UITableViewDataSource,UITableViewSeparatorDelegate>
{
    UITableViewCell *_headerCell;
    UITableViewCell *_titleCell;
    
    UILabel *_priceLabel;
    
    UILabel *_selfActivateLabel;
}
@property (nonatomic,retain) NSMutableDictionary<NSIndexPath *, UITableViewCell *> *cells;
@property (nonatomic,retain) UIImageView *headerImageView;
@property (nonatomic,retain) UILabel *titleLabel;
@end

@implementation YYKPaymentPopView

DefineLazyPropertyInitialization(NSMutableDictionary, cells)

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.separatorColor = [UIColor colorWithWhite:0.2 alpha:1];
        self.backgroundColor = [UIColor clearColor];
        self.separatorColor = [UIColor lightGrayColor];
        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kFooterHeight)];
        self.tableFooterView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
        [self registerClass:[YYKPayPointTypeCell class] forCellReuseIdentifier:kPayPointTypeCellReusableIdentifier];
        
        _selfActivateLabel = [[UILabel alloc] init];
        _selfActivateLabel.textAlignment = NSTextAlignmentCenter;
        NSString *selfActiString = @"支付完成后还需要重新支付？";
        _selfActivateLabel.attributedText = [[NSAttributedString alloc] initWithString:selfActiString attributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                                                                                   NSUnderlineStyleAttributeName:@1,
                                                                                                                   NSFontAttributeName:[UIFont systemFontOfSize:14.]}];
        [self.tableFooterView addSubview:_selfActivateLabel];
        {
            [_selfActivateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.tableFooterView);
            }];
        }
        @weakify(self);
        [self.tableFooterView bk_whenTapped:^{
            @strongify(self);
            SafelyCallBlock(self.footerAction, self);
        }];
        
        [self aspect_hookSelector:@selector(reloadData)
                      withOptions:AspectPositionAfter
                       usingBlock:^(id<AspectInfo> aspectInfo)
        {
            YYKPaymentPopView *thisTableView = [aspectInfo instance];
            
            NSUInteger svipRow = 1;
            if ([YYKUtil isVIP] && ![YYKUtil isSVIP]) {
                svipRow = 0;
            }
            [thisTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:thisTableView.payPointType==YYKPayPointTypeSVIP?svipRow:0
                                                                   inSection:PayPointTypeSection]
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
        } error:nil];
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
    cellHeights += kFooterHeight;
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
    cell.backgroundColor = self.tableFooterView.backgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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

- (void)setPayPointType:(YYKPayPointType)payPointType {
    _payPointType = payPointType;
    
    if (payPointType == YYKPayPointTypeSVIP) {
        self.headerImageView.image = [UIImage imageNamed:@"svip_payment_header"];
        
        BOOL isUpgrade = [YYKUtil isVIP] && ![YYKUtil isSVIP];
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@会员\n立即解锁海量爽片", isUpgrade ? @"升级为":@"开通", kSVIPText];
    } else {
        self.headerImageView.image = [UIImage imageNamed:@"vip_payment_header"];
        self.titleLabel.text = @"开通VIP会员\n立即解锁海量爽片";
    }
}

- (UIImageView *)headerImageView {
    if (_headerImageView) {
        return _headerImageView;
    }
    
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headerImageView.clipsToBounds = YES;
    [_headerImageView addSubview:self.titleLabel];
    {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_headerImageView).multipliedBy(0.9);
            make.centerX.equalTo(_headerImageView);
        }];
    }
    return _headerImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel) {
        return _titleLabel;
    }
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = kExExExBigFont;
    _titleLabel.numberOfLines = 2;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    return _titleLabel;
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
            [_headerCell addSubview:self.headerImageView];
            {
                [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(_headerCell);
                }];
            }

            UIButton *closeButton = [[UIButton alloc] init];
            closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
            [_headerCell addSubview:closeButton];
            {
                [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.right.equalTo(_headerCell);
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
    } else if (indexPath.section == PayPointTypeSection) {
        YYKPayPointTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayPointTypeCellReusableIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL isUpgrade = [YYKUtil isVIP] && ![YYKUtil isSVIP];
        if (indexPath.row == 0 && !isUpgrade) {
            cell.titleLabel.text = @"普通VIP";
            cell.subtitleLabel.text = [NSString stringWithFormat:@"可观看除%@区的所有视频",kSVIPShortText];
            cell.currentPrice = [[YYKSystemConfigModel sharedModel] paymentPriceWithPayPointType:YYKPayPointTypeVIP] / 100.;
            cell.originalPrice = [YYKSystemConfigModel sharedModel].originalPayAmount / 100.;
        } else {
            cell.userInteractionEnabled = YES;
            cell.titleLabel.text = isUpgrade ? [NSString stringWithFormat:@"升级成为%@",kSVIPText] : kSVIPText;
            cell.subtitleLabel.text = @"可观看所有视频";
            cell.currentPrice = [[YYKSystemConfigModel sharedModel] paymentPriceWithPayPointType:YYKPayPointTypeSVIP] / 100.;
            cell.originalPrice = [YYKSystemConfigModel sharedModel].originalSVIPPayAmount / 100.;
        }
        return cell;
    } else {
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        return self.cells[cellIndexPath];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == PayPointTypeSection) {
        return [YYKUtil isVIP] ? 1 : 2;
    } else if (section == PaymentTypeSection) {
        return self.cells.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HeaderImageSection) {
        return CGRectGetWidth(tableView.bounds) / kHeaderImageScale;
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

- (BOOL)tableView:(UITableView *)tableView hasSeparatorBetweenIndexPath:(NSIndexPath *)lowerIndexPath andIndexPath:(NSIndexPath *)upperIndexPath {
    return lowerIndexPath.section == PayPointTypeSection;
}
@end
