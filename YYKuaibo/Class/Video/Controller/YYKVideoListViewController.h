//
//  YYKVideoListViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@class YYKVideoListViewController;
@protocol YYKVideoListViewControllerDelegate <NSObject>

@required
- (void)videoListViewController:(YYKVideoListViewController *)viewContorller beginLoadingVideosWithPaging:(BOOL)isPaging;
- (YYKChannel *)channelForCurrentVideosInVideoListViewController:(YYKVideoListViewController *)viewController;

@end

@interface YYKVideoListViewController : YYKBaseViewController

@property (nonatomic,weak) id<YYKVideoListViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray<YYKProgram *> *videos;
@property (nonatomic) UIColor *tagBackgroundColor;

- (void)disableVideoLoadingWithNotifiedText:(NSString *)text;
- (void)notifyNoMoreVideos;
- (void)endVideosLoading;

- (void)reloadVideoList;

//@property (nonatomic,retain) YYKChannel *channel;

//- (instancetype)init __attribute__((unavailable("Use -initWithChannel: instead")));
//- (instancetype)initWithChannel:(YYKChannel *)channel;

@end
