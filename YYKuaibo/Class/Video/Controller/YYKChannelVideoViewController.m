//
//  YYKChannelVideoViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelVideoViewController.h"
#import "YYKChannelProgramModel.h"

@interface YYKChannelVideoViewController () <YYKVideoListViewControllerDelegate>
@property (nonatomic,retain) YYKChannelProgramModel *videoModel;
@end

@implementation YYKChannelVideoViewController

DefineLazyPropertyInitialization(YYKChannelProgramModel, videoModel)

- (instancetype)initWithChannel:(YYKChannel *)channel {
    self = [super init];
    if (self) {
        self.delegate = self;
        _channel = channel;
        
        if (channel.type.unsignedIntegerValue == YYKProgramTypePicture) {
            self.presentationStyle = YYKVideoListPortraitStyle;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _channel.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YYKVideoListViewControllerDelegate

- (void)videoListViewController:(YYKVideoListViewController *)viewContorller beginLoadingVideosWithPaging:(BOOL)isPaging {
    
    if (isPaging && ![YYKUtil isVIP] && self.videoModel.fetchedVideoChannel.page.unsignedIntegerValue > 1) {
        [self disableVideoLoadingWithNotifiedText:@"成为VIP后，上拉或点击加载更多"];
        [self payForPayPointType:QBPayPointTypeVIP];
        return ;
    }

    @weakify(self);
    [self.videoModel fetchVideosInColumn:self.channel.columnId
                                    page:isPaging?self.videoModel.fetchedVideoChannel.page.unsignedIntegerValue+1:1
                  withCompletionHandler:^(BOOL success, id obj)
     {
         @strongify(self);
         if (!self) {
             return ;
         }

         [self endVideosLoading];

         if (success) {
             if (!isPaging) {
                 [self.videos removeAllObjects];
             }

             YYKChannel *videos = obj;
             if (videos.programList) {
                 [self.videos addObjectsFromArray:videos.programList];
                 [self reloadVideoList];
             }

             if (videos.page.unsignedIntegerValue * videos.pageSize.unsignedIntegerValue >= videos.items.unsignedIntegerValue) {
                 [self notifyNoMoreVideos];
             }
         }
     }];
}

- (YYKChannel *)channelForCurrentVideosInVideoListViewController:(YYKVideoListViewController *)viewController {
    return self.videoModel.fetchedVideoChannel;
}
@end
