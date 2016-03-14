//
//  UIScrollView+Refresh.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (Refresh)

- (void)YYK_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)YYK_triggerPullToRefresh;
- (void)YYK_endPullToRefresh;

- (void)YYK_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)YYK_pagingRefreshNoMoreData;

@end
