//
//  YYKSearchResultViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSearchResultViewController.h"
#import "YYKVideoCell.h"
#import "YYKSearchModel.h"
#import "YYKKeyword.h"

static NSString *const kVideoCellReusableIdentifier = @"VideoCellReusableIdentifier";

@interface YYKSearchResultViewController () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) YYKSearchModel *searchModel;
@property (nonatomic,retain) NSMutableArray<YYKProgram *> *resultPrograms;
@end

@implementation YYKSearchResultViewController

DefineLazyPropertyInitialization(YYKSearchModel, searchModel)
DefineLazyPropertyInitialization(NSMutableArray, resultPrograms)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2;
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kVideoCellReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCV YYK_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadSearchResultsWithKeyword:self.searchedKeyword forNextPage:YES completionHandler:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchKeyword:(YYKKeyword *)keyword withCompletionHandler:(YYKCompletionHandler)completionHandler {
    _searchedKeyword = keyword;
    [keyword markSearched];
    
    [self.resultPrograms removeAllObjects];
    [self->_layoutCV reloadData];
    
    [self loadSearchResultsWithKeyword:keyword forNextPage:NO completionHandler:completionHandler];
}

- (void)loadSearchResultsWithKeyword:(YYKKeyword *)keyword
                         forNextPage:(BOOL)isForNextPage
                   completionHandler:(YYKCompletionHandler)completionHandler
{
    @weakify(self);
    [self.view beginLoading];
    [self.searchModel searchKeywords:keyword.text
                        isTagKeyword:keyword.isTag
                              inPage:isForNextPage ? self.searchModel.searchedResults.page.unsignedIntegerValue + 1 : 1
               withCompletionHandler:^(YYKSearchResults *results, NSError *error)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self.view endLoading];
        [self->_layoutCV YYK_endPullToRefresh];
        
        if (results) {

            if (results.programList) {
                [self.resultPrograms addObjectsFromArray:results.programList];
                [self->_layoutCV reloadData];
            }
            
            if (results.page.unsignedIntegerValue * results.pageSize.unsignedIntegerValue >= results.items.unsignedIntegerValue) {
                [self->_layoutCV YYK_pagingRefreshNoMoreData];
            }
        }
        
        SafelyCallBlock(completionHandler, results.programList.count > 0, error);
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:[YYKUtil currentTabPageIndex] subTabIndex:[YYKUtil currentSubTabPageIndex] forSlideCount:1];
}

#pragma mark - UICollectionViewDelegateFlowLayout,UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultPrograms.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellReusableIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    cell.tagBackgroundColor = [UIColor darkPink];
    
    if (indexPath.item < self.resultPrograms.count) {
        YYKProgram *program = self.resultPrograms[indexPath.item];
        
        cell.imageURL = [NSURL URLWithString:program.coverImg];
        cell.title = program.title;
        cell.tagText = program.tag;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat itemWidth = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(itemWidth, [YYKVideoCell heightRelativeToWidth:itemWidth withScale:5./3.]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.resultPrograms.count) {
        YYKProgram *program = self.resultPrograms[indexPath.item];
        
        YYKChannel *channel = [[YYKChannel alloc] init];
        channel.columnId = program.columnId;
        channel.type = program.type;
        channel.realColumnId = program.realColumnId;
        [self switchToPlayProgram:program programLocation:indexPath.item inChannel:channel];
    }
}
@end
