//
//  UIScrollView+Refresh.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (Refresh)

- (void)JQK_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)JQK_triggerPullToRefresh;
- (void)JQK_endPullToRefresh;

- (void)JQK_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)JQK_pagingRefreshNoMoreData;

@end
