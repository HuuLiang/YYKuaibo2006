//
//  YYKSpreadViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/19.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSpreadViewController.h"
#import "YYKSpreadCell.h"
#import "YYKAppSpreadModel.h"
#import "YYKSystemConfigModel.h"

static NSString *const kSpreadCellReusableIdentifier = @"SpreadCellReusableIdentifier";

@interface YYKSpreadViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIImageView *_headerImageView;
    UILabel *_priceLabel;
    
    UICollectionView *_layoutCollectionView;
}
@property (nonatomic,retain) YYKAppSpreadModel *appSpreadModel;
@end

@implementation YYKSpreadViewController

DefineLazyPropertyInitialization(YYKAppSpreadModel, appSpreadModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
    
    if (![YYKUtil isVIP]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        _headerImageView = [[UIImageView alloc] init];
        _headerImageView.userInteractionEnabled = YES;
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont systemFontOfSize:14.];
        _priceLabel.textColor = [UIColor redColor];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        [_headerImageView addSubview:_priceLabel];
        {
            [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_headerImageView);
                make.top.equalTo(_headerImageView.mas_centerY);
                make.width.equalTo(_headerImageView).multipliedBy(0.1);
                
            }];
        }
        
        @weakify(self);
        [_headerImageView bk_whenTapped:^{
            @strongify(self);
            if (![YYKUtil isVIP]) {
                [self payForPayPointType:YYKPayPointTypeVIP];
            };
        }];
        [self.view addSubview:_headerImageView];
        {
            [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self.view);
                make.height.equalTo(_headerImageView.mas_width).multipliedBy(210./900);
            }];
        }
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
//    layout.sectionInset = UIEdgeInsetsMake(layout.minimumInteritemSpacing, layout.minimumInteritemSpacing, layout.minimumInteritemSpacing, layout.minimumInteritemSpacing);
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = [UIColor clearColor];
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[YYKSpreadCell class] forCellWithReuseIdentifier:kSpreadCellReusableIdentifier];
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_headerImageView?_headerImageView.mas_bottom:self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCollectionView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadHeaderImage];
        [self loadSpreadApps];
    }];
    [_layoutCollectionView YYK_triggerPullToRefresh];
    
    [self.navigationController.navigationBar bk_whenTouches:1 tapped:5 handler:^{
        NSString *baseURLString = [YYK_BASE_URL stringByReplacingCharactersInRange:NSMakeRange(0, YYK_BASE_URL.length-6) withString:@"******"];
        [[YYKHudManager manager] showHudWithText:[NSString stringWithFormat:@"Server:%@\nChannelNo:%@\nPackageCertificate:%@\npV:%@/%@", baseURLString, YYK_CHANNEL_NO, YYK_PACKAGE_CERTIFICATE, YYK_REST_PV, YYK_PAYMENT_PV]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_layoutCollectionView reloadData];
}

- (void)loadHeaderImage {
    if ([YYKUtil isVIP]) {
        return ;
    }
    
    @weakify(self);
    YYKSystemConfigModel *systemConfigModel = [YYKSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (success) {
            @weakify(self);
            [self->_headerImageView sd_setImageWithURL:[NSURL URLWithString:systemConfigModel.spreadTopImage]
                                      placeholderImage:[UIImage imageNamed:@"placeholder_5_1"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {
                 @strongify(self);
                 if (!self) {
                     return ;
                 }
                 
                 if (image) {
                     NSUInteger showPrice = systemConfigModel.payAmount;
                     BOOL showInteger = showPrice % 100 == 0;
                     self->_priceLabel.text = showInteger ? [NSString stringWithFormat:@"%ld", showPrice/100] : [NSString stringWithFormat:@"%.2f", showPrice/100.];
                 } else {
                     self->_priceLabel.text = nil;
                 }
             }];
        }
    }];
    
}

- (void)loadSpreadApps {
    @weakify(self);
    [self.appSpreadModel fetchAppSpreadWithCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutCollectionView YYK_endPullToRefresh];
        
        if (success) {
            [self->_layoutCollectionView reloadData];
        }
    }];
}

- (void)onPaidNotification {
    [_headerImageView removeFromSuperview];
    _headerImageView = nil;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    [_layoutCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKSpreadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpreadCellReusableIdentifier forIndexPath:indexPath];
    //YYKSpreadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSpreadCellReusableIdentifier forIndexPath:indexPath];
    cell.backgroundColor = collectionView.backgroundColor;
    cell.placeholderImage = [UIImage imageNamed:@"placeholder_5_2"];
    
    if (indexPath.item < self.appSpreadModel.fetchedSpreadChannel.programList.count) {
        YYKProgram *appSpread = self.appSpreadModel.fetchedSpreadChannel.programList[indexPath.item];
        cell.imageURL = [NSURL URLWithString:appSpread.coverImg];
        cell.isInstalled = NO;
        
        [YYKUtil checkAppInstalledWithBundleId:appSpread.specialDesc completionHandler:^(BOOL installed) {
            if (installed) {
                cell.isInstalled = YES;
            }
        }];
    } else {
        cell.imageURL = nil;
        cell.isInstalled = NO;
    }
//        YYKProgram *appSpread = self.appSpreadModel.fetchedSpreads[indexPath.item];
//        cell.title = appSpread.title;
//        cell.imageURL = [NSURL URLWithString:appSpread.coverImg];
//        cell.isInstalled = NO;
//        

//    } else {
//        cell.title = nil;
//        cell.imageURL = nil;
//        cell.isInstalled = NO;
//    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.appSpreadModel.fetchedSpreadChannel.programList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    const CGFloat fullWidth = CGRectGetWidth(collectionView.bounds) - layout.sectionInset.left - layout.sectionInset.right;
//    const CGFloat itemWidth = (fullWidth - 2 * layout.minimumInteritemSpacing) / 3;
//    const CGFloat itemHeight = itemWidth + 20;
    return CGSizeMake(fullWidth, fullWidth * 0.4);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKProgram *appSpread = self.appSpreadModel.fetchedSpreadChannel.programList[indexPath.item];
    if (appSpread.offUrl.length > 0  && [YYKUtil isVIP]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appSpread.offUrl]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appSpread.videoUrl]];
    }
    
    
    [[YYKStatsManager sharedManager] statsCPCWithProgram:appSpread
                                         programLocation:indexPath.item
                                               inChannel:self.appSpreadModel.fetchedSpreadChannel
                                             andTabIndex:self.tabBarController.selectedIndex
                                             subTabIndex:NSNotFound
                                         isProgramDetail:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:NSNotFound forSlideCount:1];
}
@end
