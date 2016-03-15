//
//  YYKVideoLibViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoLibViewController.h"
#import "YYKVideoLibModel.h"
#import "YYKVideoCell.h"

static NSString *const kVideoLibCellReusableIdentifier = @"VideoLibCellReusableIdentifier";

@interface YYKVideoLibViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCollectionView;
}
@property (nonatomic,retain) YYKVideoLibModel *videoLibModel;
@property (nonatomic,retain) NSMutableArray<YYKVideo *> *videos;
@end

@implementation YYKVideoLibViewController

DefineLazyPropertyInitialization(YYKVideoLibModel, videoLibModel)
DefineLazyPropertyInitialization(NSMutableArray, videos)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kDefaultCollectionViewInteritemSpace;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    layout.sectionInset = UIEdgeInsetsMake(layout.minimumInteritemSpacing, layout.minimumInteritemSpacing, layout.minimumInteritemSpacing, layout.minimumInteritemSpacing);
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
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
        [self loadVideosWithRefreshFlag:YES];
    }];
    [_layoutCollectionView YYK_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadVideosWithRefreshFlag:NO];
    }];
    [_layoutCollectionView YYK_triggerPullToRefresh];
    
}

- (void)loadVideosWithRefreshFlag:(BOOL)isRefresh {
    @weakify(self);
    [self.videoLibModel fetchVideosInPage:isRefresh?1:self.videoLibModel.fetchedVideos.page.unsignedIntegerValue+1
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
            
            YYKVideos *videos = obj;
            [self.videos addObjectsFromArray:videos.programList];
            [self->_layoutCollectionView reloadData];
            
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

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoLibCellReusableIdentifier forIndexPath:indexPath];

    if (indexPath.item < self.videos.count) {
        YYKVideo *video = self.videos[indexPath.item];
        
        cell.title = video.title;
        cell.imageURL = [NSURL URLWithString:video.coverImg];
        cell.showPlayIcon = YES;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds) - layout.sectionInset.left - layout.sectionInset.right;
    if (indexPath.item == 0) {
        return CGSizeMake(fullWidth, fullWidth/2+[YYKVideoCell footerViewHeight]);
    } else {
        const CGFloat width = (fullWidth-layout.minimumInteritemSpacing)/2;
        return CGSizeMake(width, width * 1050./825. + [YYKVideoCell footerViewHeight]);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVideo *video = self.videos[indexPath.item];
    [self switchToPlayProgram:(YYKProgram *)video];
}
@end
