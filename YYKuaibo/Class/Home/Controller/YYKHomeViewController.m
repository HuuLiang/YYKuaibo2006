//
//  YYKHomeViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController.h"
#import "YYKVideoCell.h"
#import "YYKVideoSectionHeader.h"
#import "YYKBanneredProgramModel.h"
#import "YYKChannelVideoViewController.h"
#import <SDCycleScrollView.h>

static NSString *const kBannerCellReusableIdentifier = @"BannerCellReusableIdentifier";
static NSString *const kVideoLibCellReusableIdentifier = @"VideoLibCellReusableIdentifier";
static NSString *const kSpreadCellReusableIdentifier = @"SpreadCellReusableIdentifier";
static NSString *const kSectionHeaderReusableIdentifier = @"SectionHeaderReusableIdentifier";

typedef NS_ENUM(NSUInteger, YYKHomeSection) {
    YYKHomeSectionBanner,
    YYKHomeSectionTrial,
    YYKHomeSectionChannelOffset
};

@interface YYKHomeViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SDCycleScrollViewDelegate>
{
    UICollectionView *_layoutCollectionView;
    
    UICollectionViewCell *_bannerCell;
    SDCycleScrollView *_bannerView;
}
@property (nonatomic,retain) YYKBanneredProgramModel *programModel;
@property (nonatomic) BOOL hasShownSpreadBanner;
@end

@implementation YYKHomeViewController

DefineLazyPropertyInitialization(YYKBanneredProgramModel, programModel)

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    @weakify(self);
    _bannerView = [[SDCycleScrollView alloc] init];
    _bannerView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    _bannerView.autoScrollTimeInterval = 3;
    _bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _bannerView.delegate = self;
    _bannerView.backgroundColor = [UIColor clearColor];
    _bannerView.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    [_bannerView aspect_hookSelector:@selector(scrollViewDidEndDragging:willDecelerate:)
                         withOptions:AspectPositionAfter
                          usingBlock:^(id<AspectInfo> aspectInfo, UIScrollView *scrollView, BOOL decelerate)
    {
        @strongify(self);
        [[YYKStatsManager sharedManager] statsTabIndex:[YYKUtil currentTabPageIndex]
                                           subTabIndex:[YYKUtil currentSubTabPageIndex]
                                             forBanner:self.programModel.fetchedBannerChannel.columnId
                                        withSlideCount:1];
    } error:nil];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    YYKHomeCollectionViewLayout *layout = [[YYKHomeCollectionViewLayout alloc] init];
    layout.minimumInteritemSpacing = kDefaultCollectionViewInteritemSpace;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    if ([layout respondsToSelector:@selector(sectionHeadersPinToVisibleBounds)]) {
        layout.sectionHeadersPinToVisibleBounds = YES;
    }
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kVideoLibCellReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBannerCellReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSpreadCellReusableIdentifier];
    [_layoutCollectionView registerClass:[YYKVideoSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderReusableIdentifier];
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

    [_layoutCollectionView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadPrograms];
    }];
    [_layoutCollectionView YYK_triggerPullToRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
}

- (void)loadPrograms {
    @weakify(self);
    [self.programModel fetchProgramsInSpace:YYKBanneredProgramSpaceHome withCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutCollectionView YYK_endPullToRefresh];
        
        if (success) {
            [self->_layoutCollectionView reloadData];
            
            if (([YYKUtil launchSeq] >= 3 && [YYKUtil isNoVIP]) || [YYKUtil isAnyVIP]) {
                if (!self.hasShownSpreadBanner) {
                    [YYKUtil showSpreadBanner];
                    self.hasShownSpreadBanner = YES;
                }
            }
        }
    }];
}

- (void)refreshBannerView {
    NSMutableArray *imageUrlGroup = [NSMutableArray array];
    NSMutableArray *titlesGroup = [NSMutableArray array];
    for (YYKProgram *bannerProgram in self.programModel.fetchedBannerChannel.programList) {
        if (bannerProgram.coverImg && bannerProgram.title) {
            [imageUrlGroup addObject:bannerProgram.coverImg];
            [titlesGroup addObject:bannerProgram.title];
        }
    }
    _bannerView.imageURLStringsGroup = imageUrlGroup;
    _bannerView.titlesGroup = titlesGroup;
}

- (void)onPaidNotification {
    [_layoutCollectionView reloadSections:[NSIndexSet indexSetWithIndex:YYKHomeSectionTrial]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.programModel.fetchedVideoProgramList.count + YYKHomeSectionChannelOffset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKHomeSectionBanner) {
        if (!_bannerCell) {
            _bannerCell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCellReusableIdentifier forIndexPath:indexPath];
            [_bannerCell.contentView addSubview:_bannerView];
            {
                [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(_bannerCell.contentView);
                }];
            }
        }
        [self refreshBannerView];
        return _bannerCell;
    } else if (indexPath.section == YYKHomeSectionTrial) {
        YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoLibCellReusableIdentifier forIndexPath:indexPath];
        cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
        
        if (indexPath.row < self.programModel.fetchedTrialChannel.programList.count) {
            YYKProgram *trialProgram = self.programModel.fetchedTrialChannel.programList[indexPath.row];
            cell.title = trialProgram.title;
            cell.imageURL = [NSURL URLWithString:trialProgram.coverImg];
            cell.tagText = trialProgram.tag;
            cell.tagBackgroundColor = [UIColor featuredColorWithIndex:indexPath.section];
        } else {
            cell.title = nil;
            cell.imageURL = nil;
            cell.tagText = nil;
            
        }
        return cell;
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
                    cell.tagBackgroundColor = [UIColor featuredColorWithIndex:indexPath.section];
                } else {
                    cell.title = nil;
                    cell.imageURL = nil;
                    cell.tagText = nil;
                }
                return cell;
            } else {
                UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpreadCellReusableIdentifier forIndexPath:indexPath];
                
                if (indexPath.row < channel.programList.count) {
                    YYKProgram *program = channel.programList[indexPath.row];
                    
                    if (!cell.backgroundView) {
                        cell.backgroundView = [[UIImageView alloc] init];
                    }
                    
                    UIImageView *imageView = (UIImageView *)cell.backgroundView;
                    [imageView sd_setImageWithURL:[NSURL URLWithString:program.coverImg] placeholderImage:[UIImage imageNamed:@"placeholder_5_1"]];
                }
            }
        }
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == YYKHomeSectionBanner) {
        return 1;
    } else if (section == YYKHomeSectionTrial) {
        return self.programModel.fetchedTrialChannel.programList.count;
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
    if (indexPath.section == YYKHomeSectionBanner || ![kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return nil;
    }
    
//    UIEdgeInsets edgeInsets = [self collectionView:collectionView layout:collectionView.collectionViewLayout insetForSectionAtIndex:indexPath.section];
    YYKVideoSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionHeaderReusableIdentifier forIndexPath:indexPath];
    headerView.contentView.backgroundColor = self.view.backgroundColor;
    //headerView.contentView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithHexString:@"#292a39"];
    headerView.titleColor = [UIColor blackColor];
    headerView.iconColor = [UIColor featuredColorWithIndex:indexPath.section];
    headerView.accessoryTintColor = [UIColor lightGrayColor];
    headerView.accessoryHidden = NO;
//    headerView.contentSizeOffset = UIOffsetMake(-edgeInsets.left-edgeInsets.right, 0);
    
    if (indexPath.section == YYKHomeSectionTrial) {
        headerView.title = @"试看专区";
        if ([YYKUtil isSVIP]) {
            headerView.subtitle = nil;
            headerView.accessoryHidden = YES;
        } else if ([YYKUtil isVIP]) {
            headerView.subtitle = [NSString stringWithFormat:@"成为%@", kSVIPText];
        } else {
            headerView.subtitle = @"成为VIP";
        }
        
        
        @weakify(self);
        headerView.accessoryAction = ^(id obj) {
            @strongify(self);
            if ([YYKUtil isSVIP]) {
                
            } else if ([YYKUtil isVIP]) {
                [self payForPayPointType:YYKPayPointTypeSVIP];
            } else {
                [self payForPayPointType:YYKPayPointTypeVIP];
            }
        };
    } else {
        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoProgramList.count) {
            YYKChannel *channel = self.programModel.fetchedVideoProgramList[programsIndex];
            headerView.title = channel.name;
            headerView.subtitle = channel.columnDesc;
            
            BOOL svip = [channel.programList bk_any:^BOOL(YYKProgram *obj) {
                return obj.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP;
            }];
            if (svip) {
                headerView.contentView.backgroundColor = [UIColor darkPink];
                headerView.titleColor = [UIColor whiteColor];
                headerView.iconColor = [UIColor yellowColor];
                headerView.accessoryTintColor = [UIColor whiteColor];
            }
            
            @weakify(self);
            headerView.accessoryAction = ^(YYKVideoSectionHeader *obj) {
                @strongify(self);
                YYKChannelVideoViewController *channelVideoVC = [[YYKChannelVideoViewController alloc] initWithChannel:channel];
                channelVideoVC.hidesBottomBarWhenPushed = YES;
                channelVideoVC.tagBackgroundColor = [UIColor featuredColorWithIndex:indexPath.section];
                [self.navigationController pushViewController:channelVideoVC animated:YES];
                
                [[YYKStatsManager sharedManager] statsCPCWithChannel:channel inTabIndex:[YYKUtil currentTabPageIndex]];
            };
        }
    }
    
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    
    if (indexPath.section == YYKHomeSectionBanner) {
        return CGSizeMake(fullWidth, fullWidth/2);
    } else {
        const CGFloat interItemSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;
        const UIEdgeInsets sectionInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
        const CGFloat itemWidth = (fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing)/2;
        return CGSizeMake(itemWidth, [YYKVideoCell heightRelativeToWidth:itemWidth withScale:5./3.]);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == YYKHomeSectionBanner) {
        return UIEdgeInsetsMake(0, 0, 5, 0);
    }
    return UIEdgeInsetsMake(0, 0, 5, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == YYKHomeSectionBanner) {
        return CGSizeZero;
    } else {
        return CGSizeMake(0, 40);
    }
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

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (index < self.programModel.fetchedBannerChannel.programList.count) {
        YYKProgram *program = self.programModel.fetchedBannerChannel.programList[index];
        [self switchToPlayProgram:program programLocation:index inChannel:self.programModel.fetchedBannerChannel];
    }
}
@end
