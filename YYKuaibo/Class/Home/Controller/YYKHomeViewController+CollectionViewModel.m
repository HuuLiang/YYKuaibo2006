//
//  YYKHomeViewController+CollectionViewModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/23.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController+CollectionViewModel.h"
#import "YYKVideoCell.h"
#import "YYKVideoSectionHeader.h"
#import "YYKVideoSectionFooter.h"
#import "YYKBannerCell.h"
#import "YYKHomeTrialCell.h"
#import "YYKSectionBackgroundFlowLayout.h"

#import "YYKBanneredProgramModel.h"

static const void *kYYKLayoutCollectionViewAssociatedKey = &kYYKLayoutCollectionViewAssociatedKey;

static NSString *const kSectionBackgroundReusableIdentifier = @"SectionBackgroundReusableIdentifier";
static NSString *const kBannerCellReusableIdentifier = @"BannerCellReusableIdentifier";
static NSString *const kVideoLibCellReusableIdentifier = @"VideoLibCellReusableIdentifier";
static NSString *const kSectionHeaderReusableIdentifier = @"SectionHeaderReusableIdentifier";
static NSString *const kSectionFooterReusableIdentifier = @"SectionFooterReusableIdentifier";
static NSString *const kTrialCellReusableIdentifier = @"TrialCellReusableIdentifier";

typedef NS_ENUM(NSUInteger, YYKHomeSection) {
    YYKHomeSectionBanner,
    YYKHomeSectionTrial,
    //    YYKHomeSectionRanking,
    YYKHomeSectionChannelOffset
};

@interface YYKHomeViewController () <YYKBannerCellDelegate,UICollectionViewDataSource,YYKSectionBackgroundFlowLayoutDelegate>

@end

@implementation YYKHomeViewController (CollectionViewModel)

- (UICollectionView *)layoutCollectionView {
    UICollectionView *collectionView = objc_getAssociatedObject(self, kYYKLayoutCollectionViewAssociatedKey);
    if (collectionView) {
        return collectionView;
    }
    
    YYKSectionBackgroundFlowLayout *layout = [[YYKSectionBackgroundFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kDefaultCollectionViewInteritemSpace;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    if ([layout respondsToSelector:@selector(sectionHeadersPinToVisibleBounds)]) {
        layout.sectionHeadersPinToVisibleBounds = YES;
    }
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = kDarkBackgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kVideoLibCellReusableIdentifier];
    [collectionView registerClass:[YYKBannerCell class] forCellWithReuseIdentifier:kBannerCellReusableIdentifier];
    [collectionView registerClass:[YYKVideoSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderReusableIdentifier];
    [collectionView registerClass:[YYKVideoSectionFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kSectionFooterReusableIdentifier];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:YYKElementKindSectionBackground withReuseIdentifier:kSectionBackgroundReusableIdentifier];
    [collectionView registerClass:[YYKHomeTrialCell class] forCellWithReuseIdentifier:kTrialCellReusableIdentifier];
    
    objc_setAssociatedObject(self, kYYKLayoutCollectionViewAssociatedKey, collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return collectionView;
}

- (void)reloadTrialSection {
    [self.layoutCollectionView reloadSections:[NSIndexSet indexSetWithIndex:YYKHomeSectionTrial]];
}
#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.programModel.fetchedVideoProgramList.count + YYKHomeSectionChannelOffset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKHomeSectionBanner) {
        YYKBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCellReusableIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        if (!cell.placeholderImage) {
            cell.placeholderImage = [UIImage imageNamed:@"placeholder_5_2"];
        }
        //        cell.showPageControl = YES;
        //
        //        if (!cell.backgroundImage) {
        //            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"home_banner_background" ofType:@"jpg"];
        //            cell.backgroundImage = [UIImage imageWithContentsOfFile:filePath];
        //        }
        
        NSMutableArray<YYKBannerItem *> *bannerItems = [NSMutableArray array];
        for (YYKProgram *bannerProgram in self.programModel.fetchedBannerChannel.programList) {
            [bannerItems addObject:[YYKBannerItem itemWithImageURL:[NSURL URLWithString:bannerProgram.coverImg] title:bannerProgram.title]];
        }
        cell.items = bannerItems;
        
        return cell;
    } else if (indexPath.section == YYKHomeSectionTrial) {
        YYKHomeTrialCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTrialCellReusableIdentifier forIndexPath:indexPath];
//        cell.backgroundColor = [UIColor whiteColor];
        
        if (indexPath.row < self.programModel.fetchedTrialChannel.programList.count) {
            YYKProgram *trialProgram = self.programModel.fetchedTrialChannel.programList[indexPath.row];
            cell.title = trialProgram.title;
            cell.imageURL = [NSURL URLWithString:trialProgram.coverImg];
        } else {
            cell.title = nil;
            cell.imageURL = nil;
        }
        return cell;
        //    } else if (indexPath.section == YYKHomeSectionRanking) {
        //        YYKHomeRankingRowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRankingCellReusableIdentifier forIndexPath:indexPath];
        //
        //        NSMutableArray<YYKHomeRankingRowCellItem *> *items = [NSMutableArray array];
        //        [self.programModel.fetchedRankingChannel.programList enumerateObjectsUsingBlock:^(YYKProgram * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //            YYKHomeRankingRowCellItem *item = [[YYKHomeRankingRowCellItem alloc] init];
        //            item.imageURL = [NSURL URLWithString:obj.coverImg];
        //            item.title = obj.title;
        //            item.subtitle = obj.specialDesc;
        //            item.tag = obj.tag;
        //            item.popularity = obj.spare.integerValue;
        //            [items addObject:item];
        //        }];
        //        cell.items = items;
        //
        //        @weakify(self);
        //        cell.selectionAction = ^(NSUInteger index, id obj) {
        //            @strongify(self);
        //            if (index >= self.programModel.fetchedRankingChannel.programList.count) {
        //                return ;
        //            }
        //
        //            YYKProgram *program = self.programModel.fetchedRankingChannel.programList[index];
        //            [self switchToPlayProgram:program programLocation:index inChannel:self.programModel.fetchedRankingChannel];
        //        };
        //        return cell;
    } else {
        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoProgramList.count) {
            YYKChannel *channel = self.programModel.fetchedVideoProgramList[programsIndex];
            if (channel.type.unsignedIntegerValue == YYKProgramTypeVideo) {
                YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoLibCellReusableIdentifier forIndexPath:indexPath];
                cell.placeholderImage = indexPath.row == 0 ? [UIImage imageNamed:@"placeholder_3_5"] : [UIImage imageNamed:@"placeholder_1_1"];
                
                if (indexPath.row < channel.programList.count) {
                    YYKProgram *program = channel.programList[indexPath.row];
                    cell.title = program.title;
                    cell.imageURL = [NSURL URLWithString:program.coverImg];
                    cell.tagText = program.tag;
                    cell.tagBackgroundColor = kThemeColor;
                    cell.popularity = program.spare.integerValue;
                } else {
                    cell.title = nil;
                    cell.imageURL = nil;
                    cell.tagText = nil;
                    cell.popularity = 0;
                }
                return cell;
            }
        }
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == YYKHomeSectionBanner) {
        return 1;
    } else if (section == YYKHomeSectionTrial) {
        return [YYKUtil isVIP] ? 0 : self.programModel.fetchedTrialChannel.programList.count;
        //    } else if (section == YYKHomeSectionRanking) {
        //        return 1;
    } else if (section >= YYKHomeSectionChannelOffset) {
        NSUInteger programsIndex = section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoProgramList.count) {
            YYKChannel *channel = self.programModel.fetchedVideoProgramList[programsIndex];
            return channel.programList.count;
        }
    }
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == YYKElementKindSectionBackground) {
        UICollectionReusableView *sectionBgView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionBackgroundReusableIdentifier forIndexPath:indexPath];
        sectionBgView.backgroundColor = kDefaultSectionBackgroundColor;
        return sectionBgView;
    }
    
    if (indexPath.section == YYKHomeSectionBanner) {
        return nil;
    }
    //
    //    if (indexPath.section == YYKHomeSectionRanking) {
    //        YYKHomeRankingHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kRankingHeaderReusableIdentifier forIndexPath:indexPath];
    //        headerView.title = self.programModel.fetchedRankingChannel.name;
    //        headerView.subtitle = self.programModel.fetchedRankingChannel.columnDesc;
    //        return headerView;
    //    }
    
    if (kind == UICollectionElementKindSectionHeader) {
        YYKVideoSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionHeaderReusableIdentifier forIndexPath:indexPath];
        headerView.backgroundColor = kDefaultSectionBackgroundColor;
        
        if (indexPath.section == YYKHomeSectionTrial) {
            headerView.title = @"免费试播";
        } else {
            NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
            if (programsIndex < self.programModel.fetchedVideoProgramList.count) {
                YYKChannel *channel = self.programModel.fetchedVideoProgramList[programsIndex];
                headerView.title = channel.name;
            }
        }
        return headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        YYKVideoSectionFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionFooterReusableIdentifier forIndexPath:indexPath];
        footerView.backgroundColor = kDefaultSectionBackgroundColor;
        footerView.titleColor = [UIColor colorWithHexString:@"#627a9d"];
        
        if (indexPath.section == YYKHomeSectionTrial) {
            BOOL shouldBeSVIP = [YYKUtil isVIP] && ![YYKUtil isSVIP];
            footerView.title = shouldBeSVIP ? [NSString stringWithFormat:@"成为%@ 所有爽片任意看 >>", kSVIPText] : @"怎可不尽兴 充值VIP观看完整版 >>";
            footerView.titleColor = [UIColor redColor];
            
            @weakify(self);
            footerView.tapAction = ^(id obj) {
                @strongify(self);
                
                QBPayPointType payPointType = shouldBeSVIP ? QBPayPointTypeSVIP : QBPayPointTypeVIP;
                [self payForPayPointType:payPointType];
            };
        } else {
            footerView.title = @"查看全部 >>";
            
            @weakify(self);
            footerView.tapAction = ^(id obj) {
                @strongify(self);
                NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
                if (programsIndex >= self.programModel.fetchedVideoProgramList.count) {
                    return ;
                }
                
                YYKChannel *channel = self.programModel.fetchedVideoProgramList[programsIndex];
                [self openChannel:channel];
                
            };
        }
        
        return footerView;
    }    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    
    if (indexPath.section == YYKHomeSectionBanner) {
        return CGSizeMake(fullWidth, fullWidth/2);
        //    } else if (indexPath.section == YYKHomeSectionRanking) {
        //        return self.programModel.fetchedRankingChannel.programList.count > 0 ? CGSizeMake(fullWidth, fullWidth) : CGSizeZero;
    } else {
        const CGFloat interItemSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;
        const UIEdgeInsets sectionInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
        const CGFloat itemWidth = (fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing)/2;
        
        if (indexPath.section == YYKHomeSectionTrial) {
            return CGSizeMake(itemWidth, [YYKHomeTrialCell heightRelativeToWidth:itemWidth withImageScale:5./3.]);
        }
        return CGSizeMake(itemWidth, [YYKVideoCell heightRelativeToWidth:itemWidth withScale:5./3.]);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section >= YYKHomeSectionChannelOffset || section == YYKHomeSectionTrial) {
        return UIEdgeInsetsMake(kDefaultCollectionViewInteritemSpace, kDefaultCollectionViewInteritemSpace, kDefaultCollectionViewInteritemSpace, kDefaultCollectionViewInteritemSpace);
    }
    return UIEdgeInsetsZero;//UIEdgeInsetsMake(0, 0, 5, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == YYKHomeSectionBanner) {
        return CGSizeZero;
    } else if (section == YYKHomeSectionTrial) {
        return ![YYKUtil isVIP] && self.programModel.fetchedTrialChannel.programList.count > 0 ? CGSizeMake(0, 45) : CGSizeZero;
        //    } else if (section == YYKHomeSectionRanking) {
        //        return self.programModel.fetchedRankingChannel.programList.count > 0 ? CGSizeMake(0, 45) : CGSizeZero;
    } else {
        return CGSizeMake(0, 45);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == YYKHomeSectionBanner /* || section == YYKHomeSectionRanking */ || (section == YYKHomeSectionTrial && [YYKUtil isVIP])) {
        return CGSizeZero;
    } else {
        return CGSizeMake(0, MAX(30,kScreenHeight*0.057));
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout shouldDisplaySectionBackgroundInSection:(NSUInteger)section {
    return YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:0 forSlideCount:1];
}

#pragma mark - Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKHomeSectionBanner) {
        return ;
    } else if (indexPath.section == YYKHomeSectionTrial) {
        if (indexPath.row < self.programModel.fetchedTrialChannel.programList.count) {
            YYKProgram *program = self.programModel.fetchedTrialChannel.programList[indexPath.row];
            [self switchToPlayProgram:program programLocation:indexPath.row inChannel:self.programModel.fetchedTrialChannel];
        }
    } else {
        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoProgramList.count) {
            YYKChannel *channel = self.programModel.fetchedVideoProgramList[programsIndex];
            if (indexPath.row < channel.programList.count) {
                YYKProgram *program = channel.programList[indexPath.row];
                [self switchToPlayProgram:program programLocation:indexPath.row inChannel:channel];
            }
        }
    }
}

#pragma mark - YYKBannerCellDelegate

- (void)bannerCell:(YYKBannerCell *)bannerCell didSelectItemAtIndex:(NSUInteger)index {
    if (index < self.programModel.fetchedBannerChannel.programList.count) {
        YYKProgram *program = self.programModel.fetchedBannerChannel.programList[index];
        [self switchToPlayProgram:program programLocation:index inChannel:self.programModel.fetchedBannerChannel];
    }
}

- (void)bannerCellDidEndDragging:(YYKBannerCell *)bannerCell willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:[YYKUtil currentTabPageIndex]
                                       subTabIndex:[YYKUtil currentSubTabPageIndex]
                                         forBanner:self.programModel.fetchedBannerChannel.columnId
                                    withSlideCount:1];
}

@end
