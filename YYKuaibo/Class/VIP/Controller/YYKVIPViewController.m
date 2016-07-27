//
//  YYKVIPViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPViewController.h"
#import "YYKVIPCell.h"
#import "YYKVIPBannerCell.h"
#import "YYKBanneredProgramModel.h"

static NSString *const kVIPCellReusableIdentifier = @"VIPCellReusableIdentifier";
static NSString *const kBannerCellReusableIdentifier = @"BannerCellReusableIdentifier";

@interface YYKVIPViewController () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) YYKBanneredProgramModel *vipModel;
@property (nonatomic,retain) YYKChannel *bannerChannel;
@property (nonatomic,retain) YYKChannel *videoChannel;
@end

@implementation YYKVIPViewController

DefineLazyPropertyInitialization(YYKBanneredProgramModel, vipModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[YYKVIPCell class] forCellWithReuseIdentifier:kVIPCellReusableIdentifier];
    [_layoutCV registerClass:[YYKVIPBannerCell class] forCellWithReuseIdentifier:kBannerCellReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadVIPVideos];
    }];
    [_layoutCV YYK_triggerPullToRefresh];
}

- (void)loadVIPVideos {
    @weakify(self);
    [self.vipModel fetchProgramsInSpace:YYKBanneredProgramSpaceVIP withCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutCV YYK_endPullToRefresh];
        
        if (success) {
            
            self.bannerChannel = self.vipModel.fetchedBannerChannel;
            self.videoChannel = self.vipModel.fetchedVideoProgramList.firstObject;
            
            [self->_layoutCV reloadData];
        }

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegateFlowLayout,UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.videoChannel.programList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        YYKVIPBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCellReusableIdentifier forIndexPath:indexPath];
        
        NSMutableArray<YYKVIPBannerItem *> *items = [NSMutableArray array];
        [self.bannerChannel.programList enumerateObjectsUsingBlock:^(YYKProgram * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [items addObject:[YYKVIPBannerItem itemWithImageURL:[NSURL URLWithString:obj.coverImg] title:obj.title]];
        }];
        
        cell.items = items;
        
        @weakify(self);
        cell.selectionAction = ^(NSUInteger index, id obj) {
            @strongify(self);
            if (!self) {
                return ;
            }
            
            if (index < self.bannerChannel.programList.count) {
                YYKProgram *program = self.bannerChannel.programList[index];
                [self switchToPlayProgram:program programLocation:index inChannel:self.bannerChannel shouldShowDetail:NO];
            }
        };
        return cell;
    } else {
        YYKVIPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVIPCellReusableIdentifier forIndexPath:indexPath];
        
        if (indexPath.section == 1) {
            if (indexPath.item < self.videoChannel.programList.count) {
                YYKProgram *program = self.videoChannel.programList[indexPath.item];
                cell.imageURL = [NSURL URLWithString:program.coverImg];
            }
        }
        return cell;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetWidth(collectionView.bounds)/1.8);
    } else if (indexPath.section == 1) {
        const CGFloat itemWidth = CGRectGetWidth(collectionView.bounds)/2;
        return CGSizeMake(itemWidth, itemWidth/0.8);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.item < self.videoChannel.programList.count) {
            YYKProgram *program = self.videoChannel.programList[indexPath.item];
            [self switchToPlayProgram:program programLocation:indexPath.item inChannel:self.videoChannel shouldShowDetail:NO];
        }
    }
}
@end
