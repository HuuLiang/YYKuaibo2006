//
//  YYKVIPViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/19.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPViewController.h"
#import "YYKCardSlider.h"
#import "YYKChannelModel.h"
#import "YYKVIPVideoViewController.h"
#import "YYKSVIPPopView.h"
#import "YYKWebViewController.h"
#import <UIButton+WebCache.h>
#import "NSDate+Utilities.h"

@interface YYKVIPViewController () <YYKCardSliderDelegate,YYKCardSliderDataSource,YYKSVIPPopViewDelegate>
{
    YYKCardSlider *_contentView;
    UIButton *_leftNavigationButton;
}
@property (nonatomic,retain) YYKChannelModel *channelModel;
@property (nonatomic) BOOL initialLoad;
@end

@implementation YYKVIPViewController

DefineLazyPropertyInitialization(YYKChannelModel, channelModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _contentView = [[YYKCardSlider alloc] initWithFrame:self.view.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentView.delegate = self;
    _contentView.dataSource = self;
    [self.view addSubview:_contentView];

    @weakify(self);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"svip_refresh"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self loadChannels];
    }];
    
    
    _leftNavigationButton = [[UIButton alloc] init];
    _leftNavigationButton.hidden = YES;
    [_leftNavigationButton addTarget:self action:@selector(onLeftNavigationButton) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"svip_navigation_item" ofType:@"gif"];
    [_leftNavigationButton sd_setImageWithURL:[NSURL fileURLWithPath:imagePath] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        if (image) {
            const CGFloat height = 33;
            self->_leftNavigationButton.frame = CGRectMake(0, 0, height*image.size.width/image.size.height, height);
        }
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftNavigationButton];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];

    [self loadChannels];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![YYKSVIPPopView hasShown]) {
        [YYKSVIPPopView showPopViewInWindowWithDelegate:self];
    } else {
        _leftNavigationButton.hidden = NO;
    }
}

- (void)onLeftNavigationButton {
    if (![YYKUtil isSVIP]) {
        [self payForPayPointType:QBPayPointTypeSVIP];
        return ;
    }
    
    NSDate *currentDate = [NSDate date];
    if (currentDate.hour > 3) {
        [UIAlertView bk_showAlertViewWithTitle:@"午夜专区的开放时间为\n凌晨0点到3点" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
        return ;
    }
    
    YYKWebViewController *webVC = [[YYKWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://h5tg.sqdgd.com/h5-009997/"] standbyURL:nil];
    webVC.title = @"午夜专区";
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)loadChannels {
    @weakify(self);
    [self.view beginLoading];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.channelModel fetchChannelsInSpace:YYKChannelSpaceSVIP withCompletionHandler:^(BOOL success, id obj)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self.view endLoading];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (success || !self.initialLoad) {
            [self->_contentView reloadData];
            self.initialLoad = YES;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YYKSVIPPopViewDelegate

- (void)popViewDidFinishAnimatingForHiding:(YYKSVIPPopView *)popView {
    _leftNavigationButton.hidden = NO;
}

- (CGRect)popViewAnimatingTargetRectForHiding:(YYKSVIPPopView *)popView {
    return [_leftNavigationButton convertRect:_leftNavigationButton.bounds toView:self.view.window];
}

#pragma mark - YYKCardSliderDelegate,YYKCardSliderDataSource

- (NSUInteger)numberOfCardsInCardSlider:(YYKCardSlider *)slider {
    return self.channelModel.fetchedChannels.count;
}

- (YYKCard *)cardSlider:(YYKCardSlider *)slider cardAtIndex:(NSUInteger)index {
    YYKCard *card = [slider dequeReusableCardAtIndex:index];
    card.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    card.layer.shadowOpacity = 0.5;
    card.layer.shadowOffset = CGSizeMake(1, 1);
    
    if (!card.placeholderImage) {
        card.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    }
    
    if (!card.backgroundImage) {
        card.backgroundImage = [UIImage imageNamed:@"svip_background"];
    }
    
    if (index < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[index];
        card.imageURL = [NSURL URLWithString:channel.columnImg];
        card.iconImage = [UIImage imageNamed:@"svip_icon"];
//        card.title = channel.name;
//        card.subtitle = channel.columnDesc;
    }
    
    return card;
}

- (NSString *)cardSlide:(YYKCardSlider *)slider titleAtIndex:(NSUInteger)index {
    if (index < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[index];
        return channel.name;
    }
    return nil;
}

- (NSString *)cardSlide:(YYKCardSlider *)slider descriptionAtIndex:(NSUInteger)index {
    if (index < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[index];
        return channel.columnDesc;
    }
    return nil;
}

- (void)cardSlider:(YYKCardSlider *)slider didSelectCardAtIndex:(NSUInteger)index {
    if (index < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[index];
        YYKVIPVideoViewController *videoVC = [[YYKVIPVideoViewController alloc] initWithChannel:channel];
        [self.navigationController pushViewController:videoVC animated:YES];
    }
}

- (void)cardSliderDidEndSliding:(YYKCardSlider *)slider {
    [[YYKStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:NSNotFound forSlideCount:1];
}
@end
