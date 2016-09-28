//
//  YYKCategoryViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCategoryViewController.h"

#import "YYKSectionBackgroundFlowLayout.h"
#import "YYKCategoryHeaderView.h"
#import "YYKCategoryRectTextCell.h"
#import "YYKCategoryRectImageCell.h"
#import "YYKCategoryPlainTextCell.h"
#import "YYKCategoryRoundImageCell.h"
#import "YYKCategoryAppIconCell.h"

#import "YYKCategoryModel.h"

static NSString *const kHeaderViewReusableIdentifier = @"HeaderViewReusableIdentifier";
static NSString *const kSectionBackgroundReusableIdentifier = @"SectionBackgroundReusableIdentifier";

static NSString *const kRectTextCellReusableIdentifier = @"RectTextCellReusableIdentifier";
static NSString *const kPlainTextCellReusableIdentifier = @"PlainTextCellReusableIdentifier";
static NSString *const kRectImageCellReusableIdentifier = @"RectImageCellReusableIdentifier";
static NSString *const kRoundImageCellReusableIdentifier = @"RoundImageCellReusableIdentifier";
static NSString *const kIconCellReusableIdentifier = @"IconCellReusableIdentifier";

@interface YYKCategoryViewController () <YYKSectionBackgroundFlowLayoutDelegate,UICollectionViewDataSource>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) YYKCategoryModel *categoryModel;
@property (nonatomic,retain,readonly) NSArray<YYKCategory *> *categories;
@end

@implementation YYKCategoryViewController

QBDefineLazyPropertyInitialization(YYKCategoryModel, categoryModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"分类";
    
    YYKSectionBackgroundFlowLayout *layout = [[YYKSectionBackgroundFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeMake(0, 60);
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    _layoutCV.backgroundColor = kDarkBackgroundColor;
    [_layoutCV registerClass:[YYKCategoryHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewReusableIdentifier];
    [_layoutCV registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:YYKElementKindSectionBackground withReuseIdentifier:kSectionBackgroundReusableIdentifier];
    [_layoutCV registerClass:[YYKCategoryRectTextCell class] forCellWithReuseIdentifier:kRectTextCellReusableIdentifier];
    [_layoutCV registerClass:[YYKCategoryRectImageCell class] forCellWithReuseIdentifier:kRectImageCellReusableIdentifier];
    [_layoutCV registerClass:[YYKCategoryPlainTextCell class] forCellWithReuseIdentifier:kPlainTextCellReusableIdentifier];
    [_layoutCV registerClass:[YYKCategoryRoundImageCell class] forCellWithReuseIdentifier:kRoundImageCellReusableIdentifier];
    [_layoutCV registerClass:[YYKCategoryAppIconCell class] forCellWithReuseIdentifier:kIconCellReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadCategories];
    }];
    [_layoutCV YYK_triggerPullToRefresh];
}

- (void)loadCategories {
    @weakify(self);
    [self.categoryModel fetchCategoryWithCompletionHandler:^(BOOL success, id obj) {
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
    return self.categoryModel.fetchedCategories;
}

- (YYKCategory *)categoryInSection:(NSUInteger)section {
    if (section < self.categories.count) {
     return self.categories[section];
    }
    return nil;
}

- (YYKCategoryShowMode)showModeOfCategoryInSection:(NSUInteger)section {
    if (section < self.categories.count) {
        YYKCategory *category = self.categories[section];
        return category.showMode.unsignedIntegerValue;
    }
    return YYKCategoryShowModePlainText;
}

- (YYKChannel *)channelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.categories.count) {
        YYKCategory *category = self.categories[indexPath.section];
        if (indexPath.item < category.columnList.count) {
            return category.columnList[indexPath.item];
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YYKSectionBackgroundFlowLayoutDelegate,UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.categories.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section < self.categories.count) {
        YYKCategory *category = self.categories[section];
        if (category.showMode.unsignedIntegerValue == YYKCategoryShowModeIcon) {
            return category.programList.count;
        } else {
            return category.columnList.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    YYKCategoryShowMode showMode = [self showModeOfCategoryInSection:indexPath.section];
    YYKChannel *channel = [self channelAtIndexPath:indexPath];
    
    UICollectionViewCell *cell;
    
    if (showMode == YYKCategoryShowModeRectText) {
        YYKCategoryRectTextCell *thisCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRectTextCellReusableIdentifier forIndexPath:indexPath];
        thisCell.title = channel.name;
        thisCell.isSpecial = channel.spare.boolValue;
        
        cell = thisCell;
    } else if (showMode == YYKCategoryShowModeRectImage) {
        YYKCategoryRectImageCell *thisCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRectImageCellReusableIdentifier forIndexPath:indexPath];
        thisCell.title = channel.name;
        thisCell.imageURL = [NSURL URLWithString:channel.columnImg];
        
        cell = thisCell;
    } else if (showMode == YYKCategoryShowModePlainText) {
        YYKCategoryPlainTextCell *thisCell = [collectionView dequeueReusableCellWithReuseIdentifier:kPlainTextCellReusableIdentifier forIndexPath:indexPath];
        thisCell.title = channel.name;
        thisCell.isSpecial = channel.spare.boolValue;
        
        cell = thisCell;
    } else if (showMode == YYKCategoryShowModeRoundImage) {
        YYKCategoryRoundImageCell *thisCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRoundImageCellReusableIdentifier forIndexPath:indexPath];
        thisCell.title = channel.name;
        thisCell.imageURL = [NSURL URLWithString:channel.columnImg];
        thisCell.popularity = channel.spare.integerValue;
        
        cell = thisCell;
    } else if (showMode == YYKCategoryShowModeIcon) {
        YYKCategoryAppIconCell *thisCell = [collectionView dequeueReusableCellWithReuseIdentifier:kIconCellReusableIdentifier forIndexPath:indexPath];
        
        YYKCategory *category = [self categoryInSection:indexPath.section];
        if (indexPath.item < category.programList.count) {
            YYKProgram *program = category.programList[indexPath.item];
            thisCell.title = program.title;
            thisCell.imageURL = [NSURL URLWithString:program.coverImg];
        }

        cell = thisCell;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        YYKCategoryHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                               withReuseIdentifier:kHeaderViewReusableIdentifier
                                                                                      forIndexPath:indexPath];
        headerView.backgroundColor = kDefaultSectionBackgroundColor;
        
        if (indexPath.section < self.categories.count) {
            YYKCategory *category = self.categories[indexPath.section];
            headerView.title = category.name;
        }
        return headerView;
    } else if ([kind isEqualToString:YYKElementKindSectionBackground]) {
        UICollectionReusableView *sectionBackgroundView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionBackgroundReusableIdentifier forIndexPath:indexPath];
        sectionBackgroundView.backgroundColor = kDefaultSectionBackgroundColor;
        return sectionBackgroundView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    const UIEdgeInsets sectionInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
    const CGFloat interItemSpacing = [self collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:indexPath.section];
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    
    YYKCategoryShowMode showMode = [self showModeOfCategoryInSection:indexPath.section];
    if (showMode == YYKCategoryShowModeRectText) {
        const CGFloat itemWidth = floorf((fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing * 2)/3);
        return CGSizeMake(itemWidth, 44);
    } else if (showMode == YYKCategoryShowModeRectImage) {
        const CGFloat itemWidth = floorf((fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing * 3)/4);
        return CGSizeMake(itemWidth, itemWidth);
    } else if (showMode == YYKCategoryShowModePlainText) {
        const CGFloat itemWidth = floorf((fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing * 3)/4);
        return CGSizeMake(itemWidth, 38);
    } else if (showMode == YYKCategoryShowModeRoundImage) {
        const CGFloat itemWidth = floorf((fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing * 2)/3);
        return CGSizeMake(itemWidth, [YYKCategoryRoundImageCell cellHeightRelativeToWidth:itemWidth]);
    } else if (showMode == YYKCategoryShowModeIcon) {
        const CGFloat itemWidth = floorf((fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing * 2)/3);
        return CGSizeMake(itemWidth, [YYKCategoryAppIconCell cellHeightRelativeToWidth:itemWidth]);
    }

    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    YYKCategoryShowMode showMode = [self showModeOfCategoryInSection:section];
    if (showMode == YYKCategoryShowModeRectText) {
        return 15;
    } else if (showMode == YYKCategoryShowModeRectImage || showMode == YYKCategoryShowModePlainText) {
        return 5;
    } else if (showMode == YYKCategoryShowModeIcon) {
        return 20;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 15, 10, 15);
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout shouldDisplaySectionBackgroundInSection:(NSUInteger)section {
    const NSUInteger numberOfItems = [self collectionView:collectionView numberOfItemsInSection:section];
    return numberOfItems > 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKCategoryShowMode showMode = [self showModeOfCategoryInSection:indexPath.section];
    if (showMode == YYKCategoryShowModeIcon) {
        YYKCategory *category = [self categoryInSection:indexPath.section];
        if (indexPath.item < category.programList.count) {
            [self switchToPlayProgram:category.programList[indexPath.item] programLocation:indexPath.item inChannel:category];
        }
        
    } else {
        YYKChannel *channel = [self channelAtIndexPath:indexPath];
        [self openChannel:channel];
    }
    
}
@end
