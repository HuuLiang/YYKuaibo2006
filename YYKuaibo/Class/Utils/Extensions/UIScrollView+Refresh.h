//
//  UIScrollView+Refresh.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YYKPullToRefreshStyle) {
    YYKPullToRefreshStyleDefault,
    YYKPullToRefreshStyleDissolution
};

@interface UIScrollView (Refresh)

@property (nonatomic) BOOL YYK_showLastUpdatedTime;
@property (nonatomic) BOOL YYK_showStateLabel;
@property (nonatomic,weak,readonly) UIView *YYK_refreshView;
@property (nonatomic,readonly) BOOL isRefreshing;

- (void)YYK_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)YYK_addPullToRefreshWithStyle:(YYKPullToRefreshStyle)style handler:(void (^)(void))handler;
- (void)YYK_triggerPullToRefresh;
- (void)YYK_endPullToRefresh;

- (void)YYK_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)YYK_pagingRefreshNoMoreData;
- (void)YYK_setPagingRefreshText:(NSString *)text;
@end
