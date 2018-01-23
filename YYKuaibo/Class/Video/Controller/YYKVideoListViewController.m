//
//  YYKVideoListViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoListViewController.h"
#import "YYKVideoCell.h"

static NSString *const kVideoListCellReusableIdentifier = @"VideoListCellReusableIdentifier";
static const CGFloat kVideoLibLandscapeImageScale = 5./3.;
static const CGFloat kVideoLibPortraitImageScale = 7./9.;

@interface YYKVideoListViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCollectionView;
}
@end

@implementation YYKVideoListViewController

DefineLazyPropertyInitialization(NSMutableArray, videos)

//- (instancetype)initWithChannel:(YYKChannel *)channel {
//    self = [super init];
//    if (self) {
//        _channel = channel;
//        _videoModel = [[YYKChannelProgramModel alloc] init];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kDefaultCollectionViewInteritemSpace;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    layout.sectionInset = UIEdgeInsetsMake(layout.minimumInteritemSpacing, 0, layout.minimumInteritemSpacing, 0);
    
    _layoutCollectionView = [[UICollectionView  alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kVideoListCellReusableIdentifier];
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCollectionView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(videoListViewController:beginLoadingVideosWithPaging:)]) {
            [self.delegate videoListViewController:self beginLoadingVideosWithPaging:NO];
        }
    }];
    [_layoutCollectionView YYK_addPagingRefreshWithHandler:^{
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(videoListViewController:beginLoadingVideosWithPaging:)]) {
            [self.delegate videoListViewController:self beginLoadingVideosWithPaging:YES];
        }
    }];
    [_layoutCollectionView YYK_triggerPullToRefresh];
}

- (void)disableVideoLoadingWithNotifiedText:(NSString *)text {
    [_layoutCollectionView YYK_endPullToRefresh];
    [_layoutCollectionView YYK_setPagingRefreshText:text];
}

- (void)notifyNoMoreVideos {
    [_layoutCollectionView YYK_pagingRefreshNoMoreData];
}

- (void)endVideosLoading {
    [_layoutCollectionView YYK_endPullToRefresh];
}

- (void)reloadVideoList {
    [_layoutCollectionView reloadData];
}

- (YYKChannel *)askDelegateForChannel {
    if ([self.delegate respondsToSelector:@selector(channelForCurrentVideosInVideoListViewController:)]) {
        return [self.delegate channelForCurrentVideosInVideoListViewController:self];
    }
    return nil;
}
//- (void)loadVideosForRefresh:(BOOL)isRefresh {
//    if (!isRefresh && ![YYKUtil isVIP] && self.videoModel.fetchedVideoChannel.page.unsignedIntegerValue > 3) {
//        [_layoutCollectionView YYK_endPullToRefresh];
//        [_layoutCollectionView YYK_setPagingRefreshText:@"成为VIP后，上拉或点击加载更多"];
//        [self payForPayPointType:YYKPayPointTypeVIP];
//        return ;
//    }
//    
//    @weakify(self);
//    [self.videoModel fetchVideosInColumn:self.channel.columnId
//                                   page:isRefresh?1:self.videoModel.fetchedVideoChannel.page.unsignedIntegerValue+1
//                  withCompletionHandler:^(BOOL success, id obj)
//     {
//         @strongify(self);
//         if (!self) {
//             return ;
//         }
//         
//         [self->_layoutCollectionView YYK_endPullToRefresh];
//         
//         if (success) {
//             if (isRefresh) {
//                 [self.videos removeAllObjects];
//             }
//             
//             YYKChannel *videos = obj;
//             if (videos.programList) {
//                 [self.videos addObjectsFromArray:videos.programList];
//                 [self->_layoutCollectionView reloadData];
//             }
//             
//             if (videos.page.unsignedIntegerValue * videos.pageSize.unsignedIntegerValue >= videos.items.unsignedIntegerValue) {
//                 [self->_layoutCollectionView YYK_pagingRefreshNoMoreData];
//             }
//         }
//     }];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:[YYKUtil currentTabPageIndex] subTabIndex:[YYKUtil currentSubTabPageIndex] forSlideCount:1];
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoListCellReusableIdentifier forIndexPath:indexPath];
    cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    
    if (indexPath.row < self.videos.count) {
        YYKProgram *video = self.videos[indexPath.item];
        cell.title = video.title;
        cell.imageURL = [NSURL URLWithString:video.coverImg];
        cell.tagText = video.tag;
        cell.tagBackgroundColor = self.tagBackgroundColor;
        cell.popularity = video.spare.integerValue;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    const CGFloat width = (CGRectGetWidth(collectionView.bounds) - layout.minimumInteritemSpacing - layout.sectionInset.left - layout.sectionInset.right)/2;
    const CGFloat height = [YYKVideoCell heightRelativeToWidth:width withScale:self.presentationStyle == YYKVideoListPortraitStyle ? kVideoLibPortraitImageScale : kVideoLibLandscapeImageScale];
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKProgram *video = self.videos[indexPath.item];
    [self switchToPlayProgram:video programLocation:indexPath.item inChannel:[self askDelegateForChannel]];
}

@end
