//
//  YYKRankingViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/23.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKRankingViewController.h"
#import "YYKSectionBackgroundFlowLayout.h"
#import "YYKSpecialRankingCell.h"
#import "YYKWeeklyRankingHeaderView.h"
#import "YYKWeeklyRankingRowCell.h"
#import "YYKCategoryHeaderView.h"
#import "YYKCategoryRectImageCell.h"

#import "YYKCategoryModel.h"

static NSString *const kSectionBackgroundReusableIdentifier = @"SectionBackgroundReusableIdentifier";
static NSString *const kSpecialCellReusableIdentifier = @"SpecialCellReusableIdentifier";
static NSString *const kWeeklyRankingHeaderReusableIdentifier = @"WeeklyRankingHeaderReusableIdentifier";
static NSString *const kWeeklyRankingCellReusableIdentifier = @"WeeklyRankingCellReusableIdentifier";
static NSString *const kOtherHeaderReusableIdentifier = @"OtherHeaderReusableIdentifier";
static NSString *const kOtherCellReusableIdentifier = @"OtherCellReusableIdentifier";

typedef NS_ENUM(NSUInteger, YYKRankingSection) {
    YYKSpecialRankingSection,
    YYKWeeklyRankingSection,
    YYKOtherRankingSection
};

@interface YYKRankingViewController () <YYKSectionBackgroundFlowLayoutDelegate,UICollectionViewDataSource>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) YYKCategoryModel *rankingModel;
@property (nonatomic,retain,readonly) NSArray<YYKCategory *> *categories;
@end

@implementation YYKRankingViewController

DefineLazyPropertyInitialization(YYKCategoryModel, rankingModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    YYKSectionBackgroundFlowLayout *layout = [[YYKSectionBackgroundFlowLayout alloc] init];
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:YYKElementKindSectionBackground withReuseIdentifier:kSectionBackgroundReusableIdentifier];
    [_layoutCV registerClass:[YYKSpecialRankingCell class] forCellWithReuseIdentifier:kSpecialCellReusableIdentifier];
    [_layoutCV registerClass:[YYKWeeklyRankingHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kWeeklyRankingHeaderReusableIdentifier];
    [_layoutCV registerClass:[YYKWeeklyRankingRowCell class] forCellWithReuseIdentifier:kWeeklyRankingCellReusableIdentifier];
    [_layoutCV registerClass:[YYKCategoryHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kOtherHeaderReusableIdentifier];
    [_layoutCV registerClass:[YYKCategoryRectImageCell class] forCellWithReuseIdentifier:kOtherCellReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadRanking];
    }];
    [_layoutCV YYK_triggerPullToRefresh];
}

- (void)loadRanking {
    @weakify(self);
    [self.rankingModel fetchCategoryInSpace:YYKCategorySpaceRanking withCompletionHandler:^(BOOL success, id obj) {
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

- (NSArray<YYKCategory *> *)categories {
    return self.rankingModel.fetchedCategories;
}

- (YYKCategory *)categoryInSection:(NSUInteger)section {
    if (section < self.categories.count) {
        return self.categories[section];
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:0 forSlideCount:1];
}

#pragma mark - YYKSectionBackgroundFlowLayoutDelegate,UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.categories.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section < YYKOtherRankingSection) {
        return 1;
    } else if (section < self.categories.count) {
        return self.categories[section].columnList.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    YYKCategory *category = [self categoryInSection:indexPath.section];
    
    if (indexPath.section == YYKSpecialRankingSection) {
        YYKSpecialRankingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpecialCellReusableIdentifier forIndexPath:indexPath];
        cell.title = category.name;
        cell.imageURL = [NSURL URLWithString:category.columnImg];
        return cell;
    } else if (indexPath.section == YYKWeeklyRankingSection) {
        YYKWeeklyRankingRowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWeeklyRankingCellReusableIdentifier forIndexPath:indexPath];
        
        NSMutableArray<YYKWeeklyRankingRowCellItem *> *items = [NSMutableArray array];
        [category.programList enumerateObjectsUsingBlock:^(YYKProgram * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YYKWeeklyRankingRowCellItem *item = [[YYKWeeklyRankingRowCellItem alloc] init];
            item.imageURL = [NSURL URLWithString:obj.coverImg];
            item.title = obj.title;
            item.subtitle = obj.specialDesc;
            item.tag = obj.tag;
            item.popularity = obj.spare.integerValue;
            [items addObject:item];
        }];
        cell.items = items;
        
        @weakify(self);
        cell.selectionAction = ^(NSUInteger index, id obj) {
            @strongify(self);
            if (index >= category.programList.count) {
                return ;
            }
            
            YYKProgram *program = category.programList[index];
            [self switchToPlayProgram:program programLocation:index inChannel:category];
        };
        return cell;
    } else {
        YYKCategoryRectImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOtherCellReusableIdentifier forIndexPath:indexPath];
        
        if (indexPath.item < category.columnList.count) {
            YYKChannel *channel = category.columnList[indexPath.item];
            cell.title = channel.name;
            cell.imageURL = [NSURL URLWithString:channel.columnImg];
        }
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == YYKElementKindSectionBackground) {
        UICollectionReusableView *sectionBgView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionBackgroundReusableIdentifier forIndexPath:indexPath];
        sectionBgView.backgroundColor = kLightBackgroundColor;
        return sectionBgView;
    } else if (kind == UICollectionElementKindSectionHeader) {
        YYKCategory *category = [self categoryInSection:indexPath.section];
        
        if (indexPath.section == YYKWeeklyRankingSection) {
            YYKWeeklyRankingHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kWeeklyRankingHeaderReusableIdentifier forIndexPath:indexPath];
            headerView.title = category.name;
            headerView.subtitle = category.columnDesc;
            return headerView;
        } else if (indexPath.section >= YYKOtherRankingSection) {
            YYKCategoryHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kOtherHeaderReusableIdentifier forIndexPath:indexPath];
            headerView.backgroundColor = kLightBackgroundColor;
            headerView.title = category.name;
            headerView.titleOffset = 5;
            return headerView;
        }
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    YYKCategory *category = [self categoryInSection:indexPath.section];
    
    if (indexPath.section == YYKSpecialRankingSection) {
        return CGSizeMake(fullWidth, fullWidth/2);
    } else if (indexPath.section == YYKWeeklyRankingSection) {
        return category.programList.count > 0 ? CGSizeMake(fullWidth, fullWidth) : CGSizeZero;
    } else {
        const CGFloat interItemSpacing = [self collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:indexPath.section];
        const UIEdgeInsets sectionInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
        
        const CGFloat itemWidth = (fullWidth-sectionInsets.left-sectionInsets.right-interItemSpacing)/2;
        const CGFloat itemHeight = itemWidth * 0.6;
        return CGSizeMake(itemWidth, itemHeight);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    YYKCategory *category = [self categoryInSection:section];
    
    if (section == YYKWeeklyRankingSection) {
        return category.programList.count > 0 ? CGSizeMake(0, 60) : CGSizeZero;
    } else if (section >= YYKOtherRankingSection) {
        return CGSizeMake(0, 60);
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section >= YYKOtherRankingSection) {
        return 5;
    }
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section >= YYKOtherRankingSection) {
        return UIEdgeInsetsMake(0, 5, 5, 5);
    }
    return UIEdgeInsetsZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout shouldDisplaySectionBackgroundInSection:(NSUInteger)section {
    return section >= YYKOtherRankingSection;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKCategory *category = [self categoryInSection:indexPath.section];
    
    if (indexPath.section == YYKSpecialRankingSection) {
        [self openChannel:category];
    } else if (indexPath.section >= YYKOtherRankingSection) {
        if (indexPath.item < category.columnList.count) {
            YYKChannel *channel = category.columnList[indexPath.item];
            [self openChannel:channel];
        }
    }
}
@end
