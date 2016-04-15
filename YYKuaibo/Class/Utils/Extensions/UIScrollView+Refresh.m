//
//  UIScrollView+Refresh.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <MJRefresh.h>

@implementation UIScrollView (Refresh)

- (UIColor *)YYK_refreshTextColor {
    return [UIColor colorWithWhite:0.8 alpha:1];
}

- (void)YYK_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.header) {
        MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
        refreshHeader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        refreshHeader.lastUpdatedTimeLabel.textColor = [self YYK_refreshTextColor];
        refreshHeader.stateLabel.textColor = [self YYK_refreshTextColor];
//        refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        self.header = refreshHeader;
    }
}

- (void)YYK_triggerPullToRefresh {
    [self.header beginRefreshing];
}

- (void)YYK_endPullToRefresh {
    [self.header endRefreshing];
    [self.footer resetNoMoreData];
}

- (void)YYK_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        refreshFooter.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        refreshFooter.stateLabel.textColor = [self YYK_refreshTextColor];
        self.footer = refreshFooter;
    }
}

- (void)YYK_pagingRefreshNoMoreData {
    [self.footer endRefreshingWithNoMoreData];
}
@end
