//
//  YYKRecommendViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKRecommendViewController.h"
#import "YYKSystemConfigModel.h"
#import "YYKRecommendCell.h"

static NSString *const kRecommendCellReusableIdentifier = @"RecommendCellReusableIdentifier";

@interface YYKRecommendViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIImageView *_headerImageView;
    UILabel *_priceLabel;
    
    UICollectionView *_layoutCollectionView;
}
@end

@implementation YYKRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
    
    if (![YYKUtil isPaid]) {
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
            if (![YYKUtil isPaid]) {
                [self payForProgram:nil];
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
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[YYKRecommendCell class] forCellWithReuseIdentifier:kRecommendCellReusableIdentifier];
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
    }];
    [_layoutCollectionView YYK_triggerPullToRefresh];
}

- (void)loadHeaderImage {
    if ([YYKUtil isPaid]) {
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
            [self->_headerImageView sd_setImageWithURL:[NSURL URLWithString:systemConfigModel.channelTopImage]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {
                 @strongify(self);
                 if (!self) {
                     return ;
                 }
                 
                 if (image) {
                     double showPrice = systemConfigModel.payAmount;
                     BOOL showInteger = (NSUInteger)(showPrice * 100) % 100 == 0;
                     self->_priceLabel.text = showInteger ? [NSString stringWithFormat:@"%ld", (NSUInteger)showPrice] : [NSString stringWithFormat:@"%.2f", showPrice];
                 } else {
                     self->_priceLabel.text = nil;
                 }
             }];
        }
    }];
    
}

- (void)onPaidNotification {
    [_headerImageView removeFromSuperview];
    _headerImageView = nil;
    
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
    YYKRecommendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRecommendCellReusableIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}
@end
