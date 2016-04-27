//
//  YYKVideoLibViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoLibViewController.h"
#import "YYKVideoCell.h"
#import "YYKHomeSectionHeader.h"
#import "YYKHomeProgramModel.h"
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

@interface YYKVideoLibViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SDCycleScrollViewDelegate>
{
    UICollectionView *_layoutCollectionView;
    
    UICollectionViewCell *_bannerCell;
    SDCycleScrollView *_bannerView;
}
@property (nonatomic,retain) YYKHomeProgramModel *programModel;
@property (nonatomic) BOOL hasShownSpreadBanner;
@end

@implementation YYKVideoLibViewController

DefineLazyPropertyInitialization(YYKHomeProgramModel, programModel)

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    _bannerView = [[SDCycleScrollView alloc] init];
    _bannerView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    _bannerView.autoScrollTimeInterval = 3;
    _bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _bannerView.delegate = self;
    _bannerView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kDefaultCollectionViewInteritemSpace;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    if ([layout respondsToSelector:@selector(setSectionHeadersPinToVisibleBounds:)]) {
        [layout setSectionHeadersPinToVisibleBounds:YES];
    }
    
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
    
    @weakify(self);
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
            [self refreshBannerView];
            
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
    for (YYKProgram *bannerProgram in self.programModel.fetchedBannerPrograms) {
        [imageUrlGroup addObject:bannerProgram.coverImg];
        [titlesGroup addObject:bannerProgram.title];
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
        return _bannerCell;
    } else if (indexPath.section == YYKHomeSectionTrial) {
        YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoLibCellReusableIdentifier forIndexPath:indexPath];
        
        if (indexPath.row < self.programModel.fetchedTrialVideos.count) {
            YYKProgram *trialProgram = self.programModel.fetchedTrialVideos[indexPath.row];
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
            YYKPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
            if (programs.type.unsignedIntegerValue == YYKProgramTypeVideo) {
                YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoLibCellReusableIdentifier forIndexPath:indexPath];
                if (indexPath.row < programs.programList.count) {
                    YYKProgram *program = programs.programList[indexPath.row];
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
                
                if (indexPath.row < programs.programList.count) {
                    YYKProgram *program = programs.programList[indexPath.row];
                    
                    if (!cell.backgroundView) {
                        cell.backgroundView = [[UIImageView alloc] init];
                    }
                    
                    UIImageView *imageView = (UIImageView *)cell.backgroundView;
                    [imageView sd_setImageWithURL:[NSURL URLWithString:program.coverImg]];
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
        return self.programModel.fetchedTrialVideos.count;
    } else if (section >= YYKHomeSectionChannelOffset) {
        NSUInteger programsIndex = section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoAndAdProgramList.count) {
            YYKPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
            return programs.programList.count;
        }
    }
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < YYKHomeSectionChannelOffset) {
        return nil;
    }
    
    UIEdgeInsets edgeInsets = [self collectionView:collectionView layout:collectionView.collectionViewLayout insetForSectionAtIndex:indexPath.section];
    YYKHomeSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSectionHeaderReusableIdentifier forIndexPath:indexPath];
    headerView.contentView.backgroundColor = [UIColor colorWithHexString:@"#292a39"];
    headerView.contentSizeOffset = UIOffsetMake(-edgeInsets.left-edgeInsets.right, 0);

    NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
    if (programsIndex < self.programModel.fetchedVideoAndAdProgramList.count) {
        YYKPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
        headerView.title = programs.name;
        headerView.subtitle = programs.columnDesc;
        headerView.iconURL = [NSURL URLWithString:programs.columnImg];
    }
    return headerView;
}
#pragma mark - Layout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    UIEdgeInsets edgeInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds) - edgeInsets.left - edgeInsets.right;
    const CGFloat halfWidth = (fullWidth - layout.minimumInteritemSpacing) / 2;
    if (indexPath.section == YYKHomeSectionBanner) {
        return CGSizeMake(fullWidth, fullWidth/2);
    } else if (indexPath.section == YYKHomeSectionTrial) {
        return CGSizeMake(halfWidth, halfWidth);
    } else {
        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
        if (programsIndex >= self.programModel.fetchedVideoAndAdProgramList.count) {
            return CGSizeZero;
        }
        
        YYKPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
        if (programs.type.unsignedIntegerValue == YYKProgramTypeSpread) {
            return CGSizeMake(fullWidth, fullWidth/5);
        } else if (indexPath.row == 0) {
            return CGSizeMake(fullWidth, fullWidth/2);
        } else {
            return CGSizeMake(halfWidth, halfWidth);
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == YYKHomeSectionBanner) {
        return UIEdgeInsetsZero;
    } else if (section == YYKHomeSectionTrial) {
        return UIEdgeInsetsMake(5, 5, 10, 5);
    } else {
        return UIEdgeInsetsMake(0, 5, 10, 5);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section < YYKHomeSectionChannelOffset) {
        return CGSizeZero;
    }
    
    return CGSizeMake(0, 40);
}

#pragma mark - Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKHomeSectionBanner) {
        return ;
    } else if (indexPath.section == YYKHomeSectionTrial) {
        if (indexPath.row < self.programModel.fetchedTrialVideos.count) {
            YYKProgram *program = self.programModel.fetchedTrialVideos[indexPath.row];
            [self switchToPlayProgram:program];
        }
    } else {
        NSUInteger programsIndex = indexPath.section - YYKHomeSectionChannelOffset;
        if (programsIndex < self.programModel.fetchedVideoAndAdProgramList.count) {
            YYKPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[programsIndex];
            if (indexPath.row < programs.programList.count) {
                YYKProgram *program = programs.programList[indexPath.row];
                [self switchToPlayProgram:program];
            }
        }
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (index < self.programModel.fetchedBannerPrograms.count) {
        YYKProgram *program = self.programModel.fetchedBannerPrograms[index];
        [self switchToPlayProgram:program];
    }
}
@end
