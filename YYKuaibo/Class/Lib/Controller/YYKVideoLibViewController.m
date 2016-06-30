//
//  YYKVideoLibViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/8.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoLibViewController.h"
#import "YYKVideoListModel.h"

@interface YYKVideoLibViewController () <YYKVideoListViewControllerDelegate>
@property (nonatomic,retain) YYKVideoListModel *videoModel;
@end

@implementation YYKVideoLibViewController

DefineLazyPropertyInitialization(YYKVideoListModel, videoModel)

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.tagBackgroundColor = [UIColor featuredColorWithIndex:0];
    }
    return self;
}

#pragma mark - YYKVideoListViewControllerDelegate

- (void)videoListViewController:(YYKVideoListViewController *)viewContorller beginLoadingVideosWithPaging:(BOOL)isPaging {
    if (isPaging && ![YYKUtil isVIP] && self.videoModel.fetchedVideoChannel.page.unsignedIntegerValue > 1) {
        [self disableVideoLoadingWithNotifiedText:@"成为VIP后，上拉或点击加载更多"];
        [self payForPayPointType:YYKPayPointTypeVIP];
        return ;
    }
    
    @weakify(self);
    [self.videoModel fetchVideosInSpace:YYKVideoListSpaceHot
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
