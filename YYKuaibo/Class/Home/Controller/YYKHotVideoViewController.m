//
//  YYKHotVideoViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHotVideoViewController.h"
#import "YYKVideos.h"
#import "YYKVideoListModel.h"
#import "YYKVideoCell.h"

static NSString *const kHotVideoCellReusableIdentifier = @"HotVideoCellReusableIdentifier";
static NSString *const kSpreadCellReusableIdentifier = @"SpreadCellReusableIdentifier";

@interface YYKHotVideoViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCollectionView;
}
@property (nonatomic,retain) YYKVideoListModel *hotVideoModel;
@property (nonatomic,retain) NSMutableArray<YYKVideo *> *videos;
@end

@implementation YYKHotVideoViewController

DefineLazyPropertyInitialization(YYKVideoListModel, hotVideoModel)
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
    [_layoutCollectionView registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kHotVideoCellReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSpreadCellReusableIdentifier];
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
    [self.hotVideoModel fetchVideosInSpace:YYKVideoListSpaceHot
                                      page:isRefresh?1:self.hotVideoModel.fetchedVideos.page.unsignedIntegerValue+1
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
    if (indexPath.item >= self.videos.count) {
        return nil;
    }
    
    YYKVideo *video = self.videos[indexPath.item];
    if ([video isKindOfClass:[YYKProgram class]] && ((YYKProgram *)video).type.unsignedIntegerValue == YYKProgramTypeSpread) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpreadCellReusableIdentifier forIndexPath:indexPath];
        
        if (!cell.backgroundView) {
            cell.backgroundView = [[UIImageView alloc] init];
        }
        
        UIImageView *imageView = (UIImageView *)cell.backgroundView;
        [imageView sd_setImageWithURL:[NSURL URLWithString:video.coverImg]];
        return cell;
    } else {
        YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHotVideoCellReusableIdentifier forIndexPath:indexPath];
        
        if (indexPath.item < self.videos.count) {
            YYKVideo *video = self.videos[indexPath.item];
            
            cell.title = video.title;
            cell.imageURL = [NSURL URLWithString:video.coverImg];
        }
        return cell;
    }
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
    const CGFloat itemWidth = (fullWidth-layout.minimumInteritemSpacing)/2;
    
    if (indexPath.item < self.videos.count) {
        YYKVideo *video = self.videos[indexPath.item];
        
        if ([video isKindOfClass:[YYKProgram class]] && ((YYKProgram *)video).type.unsignedIntegerValue == YYKProgramTypeSpread) {
            return CGSizeMake(fullWidth, fullWidth/5);
        } else {
            return CGSizeMake(itemWidth, itemWidth * 1050./825.);
        }
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVideo *video = self.videos[indexPath.item];
    if ([video isKindOfClass:[YYKProgram class]] && ((YYKProgram *)video).type.unsignedIntegerValue == YYKProgramTypeSpread) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:video.videoUrl]];
    } else {
        [self switchToPlayProgram:(YYKProgram *)video];
    }
}

@end
