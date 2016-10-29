//
//  YYKMineViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKMineViewController.h"
#import "YYKMineVIPCell.h"
#import "YYKMineMenuCell.h"
#import "YYKAppSpreadModel.h"
#import "YYKIconSpreadCell.h"
#import "YYKSpreadCell.h"
#import "YYKWebViewController.h"
#import "YYKSystemConfigModel.h"
#import "YYKVersionUpdateModel.h"
#import "YYKActViewController.h"
typedef NS_ENUM(NSUInteger, YYKMineSection) {
    YYKVIPSection,
    YYKMenuSection,
    YYKSpreadSection,
    YYKMineSectionCount
};

typedef NS_ENUM(NSUInteger, YYKMenuItem) {
    YYKActivationItem,
    YYKAboutUsItem,
    YYKVersionUpdateItem,
    YYKContactItem
};

static NSString *const kVIPCellReusableIdentifier = @"VIPCellReusableIdentifier";
static NSString *const kMenuCellReusableIdentifier = @"MenuCellReusableIdentifier";
static NSString *const kIconSpreadCellReusableIdentifier = @"IconSpreadCellReusableIdentifier";
static NSString *const kBannerSpreadCellReusableIdentifier = @"BannerSpreadCellReusableIdentifier";

@interface YYKMineViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) YYKAppSpreadModel *spreadModel;
@end

@implementation YYKMineViewController

DefineLazyPropertyInitialization(YYKAppSpreadModel, spreadModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[YYKMineVIPCell class] forCellWithReuseIdentifier:kVIPCellReusableIdentifier];
    [_layoutCV registerClass:[YYKMineMenuCell class] forCellWithReuseIdentifier:kMenuCellReusableIdentifier];
    [_layoutCV registerClass:[YYKIconSpreadCell class] forCellWithReuseIdentifier:kIconSpreadCellReusableIdentifier];
    [_layoutCV registerClass:[YYKSpreadCell class] forCellWithReuseIdentifier:kBannerSpreadCellReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadSpreads];
    }];
    [_layoutCV YYK_triggerPullToRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"我的订单" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        YYKActViewController *actVC = [[YYKActViewController alloc] init];
        [self.navigationController pushViewController:actVC animated:YES];
    }];
}

- (void)loadSpreads {
    @weakify(self);
    [self.spreadModel fetchAppSpreadWithCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutCV YYK_endPullToRefresh];
        
        if (success) {
            [self->_layoutCV reloadData];
        }
    }];
}

- (void)onPaidNotification {
    [_layoutCV reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (YYKMineSection)sectionTypeWithSectionIndex:(NSUInteger)sectionIndex {
    if (![YYKUtil isAllVIPs]) {
        return sectionIndex;
    } else {
        return sectionIndex + 1;
    }
}
#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return YYKMineSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self sectionTypeWithSectionIndex:section] == YYKVIPSection) {
        return 1;
    } else if ([self sectionTypeWithSectionIndex:section] == YYKMenuSection) {
        return [YYKUtil isAnyVIP] ? 4 : 3;
    } else if ([self sectionTypeWithSectionIndex:section] == YYKSpreadSection) {
        return self.spreadModel.fetchedSpreadChannel.programList.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKVIPSection) {
        YYKMineVIPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVIPCellReusableIdentifier forIndexPath:indexPath];
        
        if ([YYKUtil isVIP] && ![YYKUtil isSVIP]) {
            cell.title = @"SVIP";
            cell.actionName = [NSString stringWithFormat:@"成为%@", kSVIPText];
        } else {
            cell.title = @"VIP";
            cell.actionName = @"成为VIP";
        }
        
        return cell;
    } else if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKMenuSection) {
        YYKMineMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMenuCellReusableIdentifier forIndexPath:indexPath];
        cell.backgroundColor = kDarkBackgroundColor;
        
        if (indexPath.item == YYKActivationItem) {
            cell.iconImage = [UIImage imageNamed:@"mine_activation"];
            cell.title = @"自助激活";
        } else if (indexPath.item == YYKAboutUsItem) {
            cell.iconImage = [UIImage imageNamed:@"mine_about"];
            cell.title = @"关于我们";
        } else if (indexPath.item == YYKVersionUpdateItem) {
            cell.iconImage = [UIImage imageNamed:@"mine_version_update"];
            cell.title = @"版本更新";
        } else if (indexPath.item == YYKContactItem) {
            cell.iconImage = [UIImage imageNamed:@"mine_contact"];
            cell.title = @"联系我们";
        }
        return cell;
    } else if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKSpreadSection) {
        
        YYKProgram *appSpread;
        if (indexPath.item < self.spreadModel.fetchedSpreadChannel.programList.count) {
            appSpread = self.spreadModel.fetchedSpreadChannel.programList[indexPath.item];
        }
        
        if ([YYKUtil isAnyVIP]) {
            YYKSpreadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerSpreadCellReusableIdentifier forIndexPath:indexPath];
            if (!cell.placeholderImage) {
                cell.placeholderImage = [UIImage imageNamed:@"placeholder_5_2"];
            }
            cell.imageURL = [NSURL URLWithString:appSpread.coverImg];
            return cell;
        } else {
            YYKIconSpreadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIconSpreadCellReusableIdentifier forIndexPath:indexPath];
            if (!cell.placeholderImage) {
                cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
            }
            cell.imageURL = [NSURL URLWithString:appSpread.spare];
            cell.title = appSpread.title;
            return cell;
        }
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKVIPSection) {
        if (![YYKUtil isAllVIPs]) {
            return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetWidth(collectionView.bounds)/2);
        }
    } else if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKMenuSection) {
        const NSUInteger numberOfItems = [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
        if (numberOfItems > 0) {
            const CGFloat itemWidth = CGRectGetWidth(collectionView.bounds) / numberOfItems;
            return CGSizeMake(itemWidth, kScreenHeight *0.12);
        }
        
    } else if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKSpreadSection) {
        if ([YYKUtil isAnyVIP]) {
            const CGFloat itemWidth = CGRectGetWidth(collectionView.bounds);
            const CGFloat itemHeight = itemWidth * 0.4;
            return CGSizeMake(itemWidth, itemHeight);
        } else {
            const CGFloat itemWidth = CGRectGetWidth(collectionView.bounds) * 0.25;
            const CGFloat itemHeight = itemWidth +30;
            return CGSizeMake(itemWidth, itemHeight);
        }
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([self sectionTypeWithSectionIndex:section] == YYKSpreadSection) {
        if ([YYKUtil isNoVIP]) {
            return 15;
        } else {
            return 5;
        }
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([self sectionTypeWithSectionIndex:section] == YYKSpreadSection && [YYKUtil isNoVIP]) {
        return [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section].left;
    }
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([self sectionTypeWithSectionIndex:section] == YYKSpreadSection && [YYKUtil isNoVIP]) {
        const CGFloat kLeftRightInsets = (long)(CGRectGetWidth(collectionView.bounds) / 6);
        return UIEdgeInsetsMake(30, kLeftRightInsets, 30, kLeftRightInsets);
    }
    return UIEdgeInsetsZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKVIPSection) {
        QBPayPointType payPointType = [YYKUtil isVIP] && ![YYKUtil isSVIP] ? QBPayPointTypeSVIP : QBPayPointTypeVIP;
        [self payForPayPointType:payPointType];
    } else if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKMenuSection) {
        YYKMineMenuCell *cell = (YYKMineMenuCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (indexPath.item == YYKActivationItem) {
            [[YYKManualActivationManager sharedManager] doActivation];
        } else if (indexPath.item == YYKAboutUsItem) {
            NSString *urlString = [YYKUtil isAnyVIP]?YYK_AGREEMENT_PAID_URL:YYK_AGREEMENT_NOTPAID_URL;
            urlString = [YYK_BASE_URL stringByAppendingString:urlString];
            
            NSString *standbyUrlString = [YYKUtil isAnyVIP]?YYK_STANDBY_AGREEMENT_PAID_URL:YYK_STANDBY_AGREEMENT_NOTPAID_URL;
            standbyUrlString = [YYK_STANDBY_BASE_URL stringByAppendingString:standbyUrlString];
            
            YYKWebViewController *webVC = [[YYKWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                         standbyURL:[NSURL URLWithString:standbyUrlString]];
            webVC.title = cell.title;
            [self.navigationController pushViewController:webVC animated:YES];
        } else if (indexPath.item == YYKVersionUpdateItem) {
            if ([YYKVersionUpdateModel sharedModel].fetchedVersionInfo.versionNo.length > 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[YYKVersionUpdateModel sharedModel].fetchedVersionInfo.linkUrl]];
            } else {
                [UIAlertView bk_showAlertViewWithTitle:@"当前版本已经是最新版本！" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
            }
        } else if (indexPath.item == YYKContactItem) {
            [YYKUtil contactCustomerService];
        }
    } else if ([self sectionTypeWithSectionIndex:indexPath.section] == YYKSpreadSection) {
        if (indexPath.item < self.spreadModel.fetchedSpreadChannel.programList.count) {
            YYKProgram *spread = self.spreadModel.fetchedSpreadChannel.programList[indexPath.item];
            [self switchToPlayProgram:spread programLocation:indexPath.item inChannel:self.spreadModel.fetchedSpreadChannel];
        }
    }
}
@end
