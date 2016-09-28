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
@property (nonatomic,retain) UILabel *errorLabel;
@end

@implementation YYKSearchResultViewController

DefineLazyPropertyInitialization(YYKSearchModel, searchModel)
DefineLazyPropertyInitialization(NSMutableArray, resultPrograms)

- (instancetype)initWithKeyword:(YYKKeyword *)keyword {
    self = [super init];
    if (self) {
        _searchedKeyword = keyword;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.searchedKeyword.text;
    
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
    [_layoutCV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadSearchResultsWithKeyword:self.searchedKeyword forNextPage:NO completionHandler:nil];
    }];
    [_layoutCV YYK_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadSearchResultsWithKeyword:self.searchedKeyword forNextPage:YES completionHandler:nil];
    }];
    [_layoutCV YYK_triggerPullToRefresh];
}

- (UILabel *)errorLabel {
    if (_errorLabel) {
        return _errorLabel;
    }
    
    _errorLabel = [[UILabel alloc] init];
    _errorLabel.textColor = kDefaultTextColor;
    _errorLabel.font = kBigFont;
    _errorLabel.hidden = YES;
    [self.view addSubview:_errorLabel];
    {
        [_errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    return _errorLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchKeyword:(YYKKeyword *)keyword withCompletionHandler:(YYKCompletionHandler)completionHandler {
    _searchedKeyword = keyword;
//    [keyword markSearched];
    
    [self.resultPrograms removeAllObjects];
    [self->_layoutCV reloadData];
    
    [self loadSearchResultsWithKeyword:keyword forNextPage:NO completionHandler:completionHandler];
}

- (void)loadSearchResultsWithKeyword:(YYKKeyword *)keyword
                         forNextPage:(BOOL)isForNextPage
                   completionHandler:(YYKCompletionHandler)completionHandler
{
    @weakify(self);
    self.errorLabel.hidden = YES;
    [self.searchModel searchKeywords:keyword.text
                        isTagKeyword:keyword.isTag
                              inPage:isForNextPage ? self.searchModel.searchedResults.page.unsignedIntegerValue + 1 : 1
               withCompletionHandler:^(YYKSearchResults *results, NSError *error)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutCV YYK_endPullToRefresh];
        
        if (results) {

            if (results.programList.count > 0) {
                [self.resultPrograms addObjectsFromArray:results.programList];
                [self->_layoutCV reloadData];
            } else {
                self.errorLabel.hidden = NO;
                self.errorLabel.text = @"您搜索的内容未能找到！";
            }
            
            if (results.page.unsignedIntegerValue * results.pageSize.unsignedIntegerValue >= results.items.unsignedIntegerValue) {
                [self->_layoutCV YYK_pagingRefreshNoMoreData];
            }
        } else {
            self.errorLabel.hidden = NO;
            self.errorLabel.text = error.userInfo[kSearchErrorMessageKey];
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
    cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    cell.tagBackgroundColor = kThemeColor;
    
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
