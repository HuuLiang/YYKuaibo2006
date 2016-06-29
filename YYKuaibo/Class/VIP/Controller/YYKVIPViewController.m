//
//  YYKVIPViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/19.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPViewController.h"
#import "YYKCardSlider.h"
#import "YYKVideoListModel.h"
#import "YYKPaymentInfo.h"

@interface YYKVIPViewController () <YYKCardSliderDelegate,YYKCardSliderDataSource>
{
    YYKCardSlider *_contentView;
}
@property (nonatomic,retain) YYKVideoListModel *videoModel;
@property (nonatomic) BOOL initialLoad;
@end

@implementation YYKVIPViewController

DefineLazyPropertyInitialization(YYKVideoListModel, videoModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
    
    _contentView = [[YYKCardSlider alloc] initWithFrame:self.view.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentView.delegate = self;
    _contentView.dataSource = self;
    [self.view addSubview:_contentView];

    @weakify(self);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"svip_refresh"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self loadVideos];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];

    [self loadVideos];
}

- (void)onPaidNotification:(NSNotification *)notification {
    if ([YYKUtil isSVIP]) {
        [_contentView reloadData];
    }
}

- (void)loadVideos {
    @weakify(self);
    [self.view beginLoading];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.videoModel fetchVideosInSpace:YYKVideoListSpaceVIP page:1 withCompletionHandler:^(BOOL success, id obj) {
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
    return self.videoModel.fetchedVideoChannel.programList.count;
}

- (YYKCard *)cardSlider:(YYKCardSlider *)slider cardAtIndex:(NSUInteger)index {
    YYKCard *card = [slider dequeReusableCardAtIndex:index];
    card.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
    
    if (index < self.videoModel.fetchedVideoChannel.programList.count) {
        YYKProgram *video = self.videoModel.fetchedVideoChannel.programList[index];
        card.imageURL = [NSURL URLWithString:video.coverImg];
        card.title = video.title;
        card.subtitle = video.specialDesc;
        card.rank = index+1;
        card.popularity = video.spare.integerValue;
        card.lightedDiamond = [YYKUtil isSVIP];
    }
    
    return card;
}

- (void)cardSlider:(YYKCardSlider *)slider didSelectCardAtIndex:(NSUInteger)index {
    if (index < self.videoModel.fetchedVideoChannel.programList.count) {
        YYKProgram *video = self.videoModel.fetchedVideoChannel.programList[index];
        [self switchToPlayProgram:video programLocation:index inChannel:self.videoModel.fetchedVideoChannel];
        
        [[YYKStatsManager sharedManager] statsCPCWithProgram:video
                                             programLocation:index
                                                   inChannel:self.videoModel.fetchedVideoChannel
                                                 andTabIndex:self.tabBarController.selectedIndex
                                                 subTabIndex:NSNotFound];
    }
}

- (void)cardSliderDidEndSliding:(YYKCardSlider *)slider {
    [[YYKStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:NSNotFound forSlideCount:1];
}
@end
