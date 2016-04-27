//
//  YYKSpreadBannerViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSpreadBannerViewController.h"
#import <SDCycleScrollView.h>
#import "YYKProgram.h"

@interface YYKSpreadBannerViewController () <SDCycleScrollViewDelegate>
{
    SDCycleScrollView *_contentView;
}
@property (nonatomic,readonly) NSUInteger currentIndex;
@end

@implementation YYKSpreadBannerViewController

- (instancetype)initWithSpreads:(NSArray<YYKProgram *> *)spreads {
    self = [super init];
    if (self) {
        _spreads = spreads;
    }
    return self;
}

- (BOOL)shouldDisplayBackgroundImage {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    @weakify(self);
    _contentView = [[SDCycleScrollView alloc] init];
    _contentView.delegate = self;
    _contentView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    _contentView.autoScrollTimeInterval = 5;
    [self.view addSubview:_contentView];
    {
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.equalTo(self.view).multipliedBy(0.8);
            make.height.equalTo(_contentView.mas_width).multipliedBy(3./5.);
        }];
    }
    
    UIButton *closeButton = [[UIButton alloc] init];
    closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self hide];
    } forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:closeButton];
    {
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(_contentView);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    
    NSMutableArray *imageUrlStrings = [NSMutableArray array];
    [_spreads enumerateObjectsUsingBlock:^(YYKProgram * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [imageUrlStrings addObject:obj.coverImg ?: @""];
    }];
    _contentView.imageURLStringsGroup = imageUrlStrings;
    
}

- (void)showInViewController:(UIViewController *)viewController {
    if ([viewController.childViewControllers containsObject:self]) {
        return ;
    }
    
    if ([viewController.view.subviews containsObject:self.view]) {
        return ;
    }
    
    _currentIndex = 0;
    [viewController addChildViewController:self];
    self.view.frame = viewController.view.bounds;
    self.view.alpha = 0;
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1;
    }];
}

- (void)hide {
    if (!self.view.superview) {
        return ;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [self cycleScrollView:_contentView didSelectItemAtIndex:_currentIndex];
    }];
}
//- (void)showInViewController:(UIViewController *)viewController {
//    @weakify(self);
//    [self loadSpreadsWithCompletionHandler:^(BOOL success, id obj) {
//        
//    }];
//}

//- (void)showInView:(UIView *)view {
//    if ([view.subviews containsObject:self.view]) {
//        return ;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (index < _spreads.count) {
        YYKProgram *spread = _spreads[index];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:spread.videoUrl]];
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    _currentIndex = index;
}
@end
