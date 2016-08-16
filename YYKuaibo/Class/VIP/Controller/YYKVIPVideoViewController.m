//
//  YYKVIPVideoViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPVideoViewController.h"
#import "YYKVIPVideoCell.h"
#import "YYKVideoSectionHeader.h"
#import "YYKChannelProgramModel.h"

static NSString *const kVideoCellReusableIdentifier = @"VideoCellReusableIdentifier";
static NSString *const kVideoHeaderReusableIdentifier = @"VideoHeaderReusableIdentifier";

@interface YYKVIPVideoViewController () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
    UIView *_topView;
    UICollectionView *_videoCV;
}
@property (nonatomic,retain) YYKChannelProgramModel *programModel;
@property (nonatomic) NSUInteger currentPage;

@property (nonatomic,retain) NSMutableArray<YYKProgram *> *programs;
@end

@implementation YYKVIPVideoViewController

DefineLazyPropertyInitialization(YYKChannelProgramModel, programModel)
DefineLazyPropertyInitialization(NSMutableArray, programs)

- (instancetype)initWithChannel:(YYKChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = [NSString stringWithFormat:@"%@专辑", _channel.name];
    
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];
    {
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.equalTo(self.view);
            make.height.equalTo(self.view).multipliedBy(0.25);
        }];
    }
    
    UIImageView *thumbImageView = [[UIImageView alloc] init];
    thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbImageView.clipsToBounds = YES;
    [thumbImageView sd_setImageWithURL:[NSURL URLWithString:_channel.columnImg] placeholderImage:[UIImage imageNamed:@"placeholder_1_1"]];
    [_topView addSubview:thumbImageView];
    {
        [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_topView).offset(kMediumHorizontalSpacing);
            make.top.equalTo(_topView).offset(kMediumVerticalSpacing);
            make.bottom.equalTo(_topView).offset(-kMediumVerticalSpacing);
            make.width.equalTo(thumbImageView.mas_height).multipliedBy(7./9.);
        }];
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = kBigFont;
    titleLabel.text = _channel.name;
    [_topView addSubview:titleLabel];
    {
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(thumbImageView.mas_right).offset(kMediumHorizontalSpacing);
            make.right.equalTo(_topView).offset(-kMediumHorizontalSpacing);
            make.top.equalTo(thumbImageView);
        }];
    }
    
    UITextView *textView = [[UITextView alloc] init];
    textView.font = kSmallFont;
    textView.textColor = [UIColor colorWithHexString:@"#555555"];
    textView.editable = NO;
    textView.backgroundColor = _topView.backgroundColor;
    textView.text = _channel.columnDesc;
    [_topView addSubview:textView];
    {
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(kSmallVerticalSpacing);
            make.left.right.equalTo(titleLabel);
            make.bottom.equalTo(thumbImageView);
        }];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = layout.minimumLineSpacing;
    
    _videoCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _videoCV.backgroundColor = self.view.backgroundColor;
    _videoCV.delegate = self;
    _videoCV.dataSource = self;
    [_videoCV registerClass:[YYKVIPVideoCell class] forCellWithReuseIdentifier:kVideoCellReusableIdentifier];
    [_videoCV registerClass:[YYKVideoSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kVideoHeaderReusableIdentifier];
    [self.view addSubview:_videoCV];
    {
        [_videoCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_topView.mas_bottom);
        }];
    }
    
    @weakify(self);
    [_videoCV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadVideosInPage:1];
    }];
    [_videoCV YYK_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadVideosInPage:self.currentPage+1];
    }];
    [_videoCV YYK_triggerPullToRefresh];
}

- (void)loadVideosInPage:(NSUInteger)page {
    @weakify(self);
    [self.programModel fetchVideosInColumn:_channel.columnId page:page withCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_videoCV YYK_endPullToRefresh];
        
        if (success) {
            if (page == 1) {
                [self.programs removeAllObjects];
            }
            
            YYKChannel *channel = obj;
            self.currentPage = channel.page.unsignedIntegerValue;
            
            if (channel.programList) {
                [self.programs addObjectsFromArray:channel.programList];
                [self->_videoCV reloadData];
            }
            
            if (self.currentPage * channel.pageSize.unsignedIntegerValue >= channel.items.unsignedIntegerValue) {
                [self->_videoCV YYK_pagingRefreshNoMoreData];
            }
        }
    }];
}

- (BOOL)shouldShowLandscapeImageAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.item+1) % 3 == 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegateFlowLayout,UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.programs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVIPVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCellReusableIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    if ([self shouldShowLandscapeImageAtIndexPath:indexPath]) {
        cell.placeholderImage = [UIImage imageNamed:@"placeholder_5_2"];
    } else {
        cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    }
    
    if (indexPath.item < self.programs.count) {
        YYKProgram *program = self.programs[indexPath.item];
        cell.imageURL = [NSURL URLWithString:program.coverImg];
        cell.title = program.title;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    YYKVideoSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kVideoHeaderReusableIdentifier forIndexPath:indexPath];
    headerView.title = @"成名作";
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const UIEdgeInsets sectionInsets = [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
    const CGFloat interItemSpacing = [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds) - sectionInsets.left - sectionInsets.right;
    
    if ([self shouldShowLandscapeImageAtIndexPath:indexPath]) {
        return CGSizeMake(fullWidth, [YYKVIPVideoCell heightRelativeToWidth:fullWidth withImageScale:2./1.]);
    } else {
        const CGFloat itemWidth = (fullWidth - interItemSpacing) / 2;
        return CGSizeMake(itemWidth, [YYKVIPVideoCell heightRelativeToWidth:itemWidth withImageScale:7./9.]);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.programs.count) {
        YYKProgram *program = self.programs[indexPath.item];
        [self switchToPlayProgram:program programLocation:indexPath.item inChannel:self.channel shouldShowDetail:NO];
    }
}
@end
