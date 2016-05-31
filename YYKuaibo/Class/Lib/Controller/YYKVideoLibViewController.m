//
//  YYKVideoLibViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/8.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoLibViewController.h"
#import "YYKVideoCell.h"
#import "YYKVideoListModel.h"

static NSString *const kVideoLibCellReusableIdentifier = @"VideoLibCellReusableIdentifier";
static const CGFloat kVideoLibImageScale = 5./3.;

@interface YYKVideoLibViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCollectionView;
}
@property (nonatomic,retain) YYKVideoListModel *videoModel;
@property (nonatomic,retain) NSMutableArray<YYKProgram *> *videos;
@end

@implementation YYKVideoLibViewController

DefineLazyPropertyInitialization(YYKVideoListModel, videoModel)
DefineLazyPropertyInitialization(NSMutableArray, videos)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    layout.sectionInset = UIEdgeInsetsMake(layout.minimumInteritemSpacing, layout.minimumInteritemSpacing, layout.minimumInteritemSpacing, layout.minimumInteritemSpacing);
    
    _layoutCollectionView = [[UICollectionView  alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kVideoLibCellReusableIdentifier];
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCollectionView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadMoviesWithRefreshFlag:YES];
    }];
    [_layoutCollectionView YYK_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadMoviesWithRefreshFlag:NO];
    }];
    [_layoutCollectionView YYK_triggerPullToRefresh];
}

- (void)loadMoviesWithRefreshFlag:(BOOL)isRefresh {
    @weakify(self);
    [self.videoModel fetchVideosInSpace:YYKVideoListSpaceHot
                                   page:isRefresh?1:self.videoModel.fetchedVideoChannel.page.unsignedIntegerValue+1
                  withCompletionHandler:^(BOOL success, id obj)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutCollectionView YYK_endPullToRefresh];
        
        if (success) {
            if (isRefresh) {
                [self.videos removeAllObjects];
            }
            
            YYKChannel *videos = obj;
            if (videos.programList) {
                [self.videos addObjectsFromArray:videos.programList];
                [self->_layoutCollectionView reloadData];
            }
            
            if (videos.page.unsignedIntegerValue * videos.pageSize.unsignedIntegerValue >= videos.items.unsignedIntegerValue) {
                [self->_layoutCollectionView YYK_pagingRefreshNoMoreData];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:[YYKUtil currentTabPageIndex] subTabIndex:[YYKUtil currentSubTabPageIndex] forSlideCount:1];
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoLibCellReusableIdentifier forIndexPath:indexPath];
    cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    
    if (indexPath.row < self.videos.count) {
        YYKProgram *video = self.videos[indexPath.item];
        cell.title = video.title;
        cell.imageURL = [NSURL URLWithString:video.coverImg];
        cell.spec = video.spec.unsignedIntegerValue;
        cell.showPlayIcon = YES;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    const CGFloat width = (CGRectGetWidth(collectionView.bounds) - layout.minimumInteritemSpacing - layout.sectionInset.left - layout.sectionInset.right)/2;
    const CGFloat height = [YYKVideoCell heightRelativeToWidth:width withScale:kVideoLibImageScale];
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKProgram *video = self.videos[indexPath.item];
    [self switchToPlayProgram:video programLocation:indexPath.item inChannel:self.videoModel.fetchedVideoChannel];
    
    [[YYKStatsManager sharedManager] statsCPCWithProgram:video
                                         programLocation:indexPath.item
                                               inChannel:self.videoModel.fetchedVideoChannel
                                             andTabIndex:[YYKUtil currentTabPageIndex]
                                             subTabIndex:[YYKUtil currentSubTabPageIndex]];
}
@end
