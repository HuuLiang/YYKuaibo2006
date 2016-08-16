//
//  YYKVideoDetailViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoDetailViewController.h"
#import "YYKVideoDetailModel.h"
#import "YYKVideoThumbCell.h"
#import "YYKVideoCell.h"
#import "YYKVideoSectionHeader.h"

typedef NS_ENUM(NSUInteger, VideoDetailSection) {
    VDThumbSection,
    VDSpreadSection,
    VDFeaturedSection,
    VDSectionCount
};

static NSString *const kVideoThumbCellReusableIdentifier = @"VideoThumbCellReusableIdentifier";
static NSString *const kSpreadCellReusableIdentifier = @"SpreadCellReusableIdentifier";
static NSString *const kFeaturedCellReusableIdentifier = @"FeaturedCellReusableIdentifier";
static NSString *const kHeaderSectionReusableIdentifier = @"HeaderSectionReusableIdentifier";

@interface YYKVideoDetailViewController () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) YYKVideoDetailModel *detailModel;
@end

@implementation YYKVideoDetailViewController

DefineLazyPropertyInitialization(YYKVideoDetailModel, detailModel)

- (instancetype)initWithVideo:(YYKProgram *)video
                videoLocation:(NSUInteger)videoLocation
                    inChannel:(YYKChannel *)channel
{
    self = [super init];
    if (self) {
        _video = video;
        _videoLocation = videoLocation;
        _channel = channel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _video.title;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kDefaultCollectionViewInteritemSpace;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[YYKVideoThumbCell class] forCellWithReuseIdentifier:kVideoThumbCellReusableIdentifier];
    [_layoutCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSpreadCellReusableIdentifier];
    [_layoutCV registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kFeaturedCellReusableIdentifier];
    [_layoutCV registerClass:[YYKVideoSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderSectionReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadVideoDetail];
    }];
    [_layoutCV YYK_triggerPullToRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
}

- (void)loadVideoDetail {
    @weakify(self);
    [self.detailModel fetchDetailOfVideo:self.video inChannel:self.channel withCompletionHandler:^(BOOL success, id obj) {
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

#pragma mark - UICollectionViewDelegateFlowLayout,UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return VDSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == VDFeaturedSection) {
        return self.detailModel.fetchedDetail.hotProgramList.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VDThumbSection) {
        YYKVideoThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoThumbCellReusableIdentifier forIndexPath:indexPath];
        cell.imageURL = [NSURL URLWithString:self.detailModel.fetchedDetail.program.coverImg];
        return cell;
    } else if (indexPath.section == VDSpreadSection) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpreadCellReusableIdentifier forIndexPath:indexPath];
        if (!cell.backgroundView) {
            cell.backgroundView = [[UIImageView alloc] init];
            cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
            cell.backgroundView.clipsToBounds = YES;
        }
        
        UIImageView *imageView = (UIImageView *)cell.backgroundView;
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.detailModel.fetchedDetail.spreadApp.coverImg]
                     placeholderImage:[UIImage imageNamed:@"placeholder_5_2"]];
        return cell;
    } else if (indexPath.section == VDFeaturedSection) {
        YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFeaturedCellReusableIdentifier forIndexPath:indexPath];
        
        if (!cell.placeholderImage) {
            cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
        }
        
        if (indexPath.item < self.detailModel.fetchedDetail.hotProgramList.count) {
            YYKProgram *featuredVideo = self.detailModel.fetchedDetail.hotProgramList[indexPath.item];
            cell.title = featuredVideo.title;
            cell.imageURL = [NSURL URLWithString:featuredVideo.coverImg];
            cell.tagText = featuredVideo.tag;
            cell.tagBackgroundColor = kThemeColor;
            cell.popularity = featuredVideo.spare.integerValue;
        }
        return cell;
    } else {
        return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    if (indexPath.section == VDThumbSection) {
        return CGSizeMake(fullWidth, fullWidth * 3 / 5);
    }
    
    const UIEdgeInsets sectionInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
    if (indexPath.section == VDSpreadSection) {
        if (self.detailModel.fetchedDetail.spreadApp && [YYKUtil isVIP]) {
            const CGFloat spreadWidth = fullWidth - sectionInsets.left - sectionInsets.right;
            return CGSizeMake(spreadWidth, spreadWidth * 1 / 5);
        } else {
            return CGSizeZero;
        }
    } else if (indexPath.section == VDFeaturedSection) {
        const CGFloat interItemSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;
        const CGFloat itemWidth = (fullWidth - sectionInsets.left - sectionInsets.right - interItemSpacing) / 2;
        return CGSizeMake(itemWidth, [YYKVideoCell heightRelativeToWidth:itemWidth withScale:5./3.]);
    } else {
        return CGSizeZero;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != VDFeaturedSection || self.detailModel.fetchedDetail.hotProgramList.count == 0) {
        return nil;
    }
    
    YYKVideoSectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderSectionReusableIdentifier forIndexPath:indexPath];
    header.title = @"热力推荐";
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == VDFeaturedSection && self.detailModel.fetchedDetail.hotProgramList.count > 0) {
        return CGSizeMake(0, 45);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == VDSpreadSection) {
        return UIEdgeInsetsMake(5, 5, 5, 5);
    } else if (section == VDFeaturedSection) {
        return UIEdgeInsetsMake(0, 5, 5, 5);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VDThumbSection) {
        [self switchToPlayProgram:self.video programLocation:self.videoLocation inChannel:self.channel shouldShowDetail:NO];
    } else if (indexPath.section == VDSpreadSection) {
        [self switchToPlayProgram:self.detailModel.fetchedDetail.spreadApp programLocation:self.videoLocation inChannel:self.channel shouldShowDetail:NO];
    } else if (indexPath.section == VDFeaturedSection) {
        if (indexPath.item < self.detailModel.fetchedDetail.hotProgramList.count) {
            YYKProgram *featuredVideo = self.detailModel.fetchedDetail.hotProgramList[indexPath.item];
            [self switchToPlayProgram:featuredVideo programLocation:indexPath.item inChannel:self.channel shouldShowDetail:YES];
        }
    }
}
@end
