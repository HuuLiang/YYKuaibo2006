//
//  YYKHomeViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController.h"
#import "YYKVideoCell.h"
#import "YYKHomeSectionHeader.h"
#import "YYKHomeProgramModel.h"
#import "YYKHomeCollectionViewLayout.h"
#import <SDCycleScrollView.h>

static NSString *const kBannerCellReusableIdentifier = @"BannerCellReusableIdentifier";
static NSString *const kVideoLibCellReusableIdentifier = @"VideoLibCellReusableIdentifier";
static NSString *const kSpreadCellReusableIdentifier = @"SpreadCellReusableIdentifier";
static NSString *const kSectionHeaderReusableIdentifier = @"SectionHeaderReusableIdentifier";

@interface YYKHomeViewController () <UICollectionViewDataSource,UICollectionViewDelegate,SDCycleScrollViewDelegate>
{
    UICollectionView *_layoutCollectionView;
    
    UICollectionViewCell *_bannerCell;
    SDCycleScrollView *_bannerView;
}
@property (nonatomic,retain) YYKHomeProgramModel *programModel;
@property (nonatomic) BOOL hasShownSpreadBanner;
@end

@implementation YYKHomeViewController

DefineLazyPropertyInitialization(YYKHomeProgramModel, programModel)

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
    _bannerView.placeholderImage = [UIImage imageNamed:@"placeholder_2_1"];
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
    
    YYKHomeCollectionViewLayout *layout = [[YYKHomeCollectionViewLayout alloc] init];
    layout.interItemSpacing = kDefaultCollectionViewInteritemSpace;

    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kVideoLibCellReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBannerCellReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSpreadCellReusableIdentifier];
    [_layoutCollectionView registerClass:[YYKHomeSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderReusableIdentifier];
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
    
}

- (void)loadPrograms {
    @weakify(self);
    [self.programModel fetchProgramsWithCompletionHandler:^(BOOL success, id obj) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.programModel.fetchedVideoAndAdProgramList.count + YYKHomeSectionChannelOffset;
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
            cell.showPlayIcon = YES;
            cell.spec = YYKVideoSpecFree;
        } else {
            cell.title = nil;
            cell.imageURL = nil;
            cell.spec = YYKVideoSpecNone;
        }
        return cell;
    } else {
        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoAndAdProgramList.count) {
            YYKChannel *channel = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
            if (channel.type.unsignedIntegerValue == YYKProgramTypeVideo) {
                YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoLibCellReusableIdentifier forIndexPath:indexPath];
                cell.placeholderImage = indexPath.row == 0 ? [UIImage imageNamed:@"placeholder_2_1"] : [UIImage imageNamed:@"placeholder_1_1"];
                
                if (indexPath.row < channel.programList.count) {
                    YYKProgram *program = channel.programList[indexPath.row];
                    cell.title = program.title;
                    cell.imageURL = [NSURL URLWithString:program.coverImg];
                    cell.showPlayIcon = YES;
                    cell.spec = program.spec.unsignedIntegerValue;
                } else {
                    cell.title = nil;
                    cell.imageURL = nil;
                    cell.spec = YYKVideoSpecNone;
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
        if (programsIndex < self.programModel.fetchedVideoAndAdProgramList.count) {
            YYKChannel *channel = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
            return channel.programList.count;
        }
    }
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < YYKHomeSectionChannelOffset) {
        return nil;
    }
    
//    UIEdgeInsets edgeInsets = [self collectionView:collectionView layout:collectionView.collectionViewLayout insetForSectionAtIndex:indexPath.section];
    YYKHomeSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionHeaderReusableIdentifier forIndexPath:indexPath];
    headerView.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];//[UIColor colorWithHexString:@"#292a39"];
//    headerView.contentSizeOffset = UIOffsetMake(-edgeInsets.left-edgeInsets.right, 0);

    NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
    if (programsIndex < self.programModel.fetchedVideoAndAdProgramList.count) {
        YYKChannel *channel = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
        headerView.title = channel.name;
        headerView.subtitle = channel.columnDesc;
        headerView.iconURL = [NSURL URLWithString:channel.columnImg];
        
        BOOL svip = [channel.programList bk_any:^BOOL(YYKProgram *obj) {
            return obj.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP;
        }];
        if (svip) {
            headerView.contentView.backgroundColor = [UIColor darkPink];
        }
    }
    return headerView;
}
#pragma mark - Layout

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
//    UIEdgeInsets edgeInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
//    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds) - edgeInsets.left - edgeInsets.right;
//    const CGFloat halfWidth = (fullWidth - layout.minimumInteritemSpacing) / 2;
//    if (indexPath.section == YYKHomeSectionBanner) {
//        return CGSizeMake(fullWidth, fullWidth/2);
//    } else if (indexPath.section == YYKHomeSectionTrial) {
//        return CGSizeMake(halfWidth, halfWidth);
//    } else {
//        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
//        if (programsIndex >= self.programModel.fetchedVideoAndAdProgramList.count) {
//            return CGSizeZero;
//        }
//        
//        YYKChannel *channel = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
//        if (channel.type.unsignedIntegerValue == YYKProgramTypeSpread) {
//            return CGSizeMake(fullWidth, fullWidth/5);
//        } else if (indexPath.row == 0) {
//            return CGSizeMake(fullWidth, fullWidth/2);
//        } else {
//            return CGSizeMake(halfWidth, halfWidth);
//        }
//    }
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    if (section == YYKHomeSectionBanner) {
//        return UIEdgeInsetsZero;
//    } else if (section == YYKHomeSectionTrial) {
//        return UIEdgeInsetsMake(5, 5, 10, 5);
//    } else {
//        return UIEdgeInsetsMake(0, 5, 10, 5);
//    }
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    if (section < YYKHomeSectionChannelOffset) {
//        return CGSizeZero;
//    }
//    
//    return CGSizeMake(0, 40);
//}

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
            
            [[YYKStatsManager sharedManager] statsCPCWithProgram:program
                                                 programLocation:indexPath.row
                                                       inChannel:self.programModel.fetchedTrialChannel
                                                     andTabIndex:self.tabBarController.selectedIndex
                                                     subTabIndex:0];
            
        }
    } else {
        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoAndAdProgramList.count) {
            YYKChannel *channel = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
            if (indexPath.row < channel.programList.count) {
                YYKProgram *program = channel.programList[indexPath.row];
                [self switchToPlayProgram:program programLocation:indexPath.row inChannel:channel];
                
                [[YYKStatsManager sharedManager] statsCPCWithProgram:program
                                                     programLocation:indexPath.row
                                                           inChannel:channel
                                                         andTabIndex:self.tabBarController.selectedIndex
                                                         subTabIndex:0];
            }
        }
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (index < self.programModel.fetchedBannerChannel.programList.count) {
        YYKProgram *program = self.programModel.fetchedBannerChannel.programList[index];
        [self switchToPlayProgram:program programLocation:index inChannel:self.programModel.fetchedBannerChannel];
        
        [[YYKStatsManager sharedManager] statsCPCWithProgram:program
                                             programLocation:index
                                                   inChannel:self.programModel.fetchedBannerChannel
                                                 andTabIndex:self.tabBarController.selectedIndex
                                                 subTabIndex:0];
    }
}
@end
