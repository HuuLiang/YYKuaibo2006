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
#import "YYKPaymentInfo.h"
#import "YYKVIPVideoViewController.h"

@interface YYKVIPViewController () <YYKCardSliderDelegate,YYKCardSliderDataSource>
{
    YYKCardSlider *_contentView;
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
    
    //self.view.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
    
//    NSString *bgImagePath = [[NSBundle mainBundle] pathForResource:@"svip_background" ofType:@"jpg"];
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:bgImagePath]];
//    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
//    backgroundImageView.clipsToBounds = YES;
//    [self.view addSubview:backgroundImageView];
//    {
//        [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
//    }
    
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];

    [self loadChannels];
}

//- (void)onPaidNotification:(NSNotification *)notification {
//    if ([YYKUtil isSVIP]) {
//        [_contentView reloadData];
//    }
//}

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
