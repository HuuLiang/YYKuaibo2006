//
//  UIScrollView+Refresh.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <MJRefresh.h>
#import <ODRefreshControl.h>

static const void *kYYKRefreshViewAssociatedKey = &kYYKRefreshViewAssociatedKey;
static const void *kYYKShowLastUpdatedTimeAssociatedKey = &kYYKShowLastUpdatedTimeAssociatedKey;
static const void *kYYKShowStateAssociatedKey = &kYYKShowStateAssociatedKey;

@implementation UIScrollView (Refresh)

- (UIColor *)YYK_refreshTextColor {
    return [UIColor colorWithWhite:0.8 alpha:1];
}

- (UIView *)YYK_refreshView {
    return objc_getAssociatedObject(self, kYYKRefreshViewAssociatedKey);
}

- (void)setYYK_showLastUpdatedTime:(BOOL)YYK_showLastUpdatedTime {
    objc_setAssociatedObject(self, kYYKShowLastUpdatedTimeAssociatedKey, @(YYK_showLastUpdatedTime), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ([self.header isKindOfClass:[MJRefreshStateHeader class]]) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.header;
        header.lastUpdatedTimeLabel.hidden = !YYK_showLastUpdatedTime;
    }
}

- (BOOL)YYK_showLastUpdatedTime {
    NSNumber *value = objc_getAssociatedObject(self, kYYKShowLastUpdatedTimeAssociatedKey);
    return value.boolValue;
}

- (void)setYYK_showStateLabel:(BOOL)YYK_showStateLabel {
    objc_setAssociatedObject(self, kYYKShowStateAssociatedKey, @(YYK_showStateLabel), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ([self.header isKindOfClass:[MJRefreshStateHeader class]]) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.header;
        header.stateLabel.hidden = !YYK_showStateLabel;
    }
}

- (BOOL)YYK_showStateLabel {
    NSNumber *value = objc_getAssociatedObject(self, kYYKShowStateAssociatedKey);
    return value.boolValue;
}

- (void)YYK_addPullToRefreshWithHandler:(void (^)(void))handler {
    [self YYK_addPullToRefreshWithStyle:YYKPullToRefreshStyleDefault handler:handler];
}

- (void)YYK_addPullToRefreshWithStyle:(YYKPullToRefreshStyle)style handler:(void (^)(void))handler {
    if (style == YYKPullToRefreshStyleDissolution) {
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self];
        refreshControl.tintColor = [UIColor grayColor];
        [refreshControl bk_addEventHandler:^(id sender) {
            if (handler) {
                handler();
            }
        } forControlEvents:UIControlEventValueChanged];
        objc_setAssociatedObject(self, kYYKRefreshViewAssociatedKey, refreshControl, OBJC_ASSOCIATION_ASSIGN);
    } else {
        if (!self.header) {
            MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
//            refreshHeader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            refreshHeader.lastUpdatedTimeLabel.textColor = [self YYK_refreshTextColor];
            refreshHeader.stateLabel.textColor = [self YYK_refreshTextColor];
            refreshHeader.lastUpdatedTimeLabel.hidden = !self.YYK_showLastUpdatedTime;
            self.header = refreshHeader;
            
            objc_setAssociatedObject(self, kYYKRefreshViewAssociatedKey, refreshHeader, OBJC_ASSOCIATION_ASSIGN);
        }
    }
}

- (void)YYK_triggerPullToRefresh {
    
    if ([self.YYK_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.YYK_refreshView;
        [refresh beginRefreshing];
    } else if ([self.YYK_refreshView isKindOfClass:[ODRefreshControl class]]) {
        ODRefreshControl *refresh = (ODRefreshControl *)self.YYK_refreshView;
        [refresh beginRefreshing];
        [refresh sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)YYK_endPullToRefresh {
    if ([self.YYK_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.YYK_refreshView;
        [refresh endRefreshing];
        [self.footer resetNoMoreData];
    } else if ([self.YYK_refreshView isKindOfClass:[ODRefreshControl class]]) {
        ODRefreshControl *refresh = (ODRefreshControl *)self.YYK_refreshView;
        [refresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.01];
    }
}

- (void)YYK_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
//        refreshFooter.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        refreshFooter.stateLabel.textColor = [self YYK_refreshTextColor];
        self.footer = refreshFooter;
    }
}

- (void)YYK_pagingRefreshNoMoreData {
    [self.footer endRefreshingWithNoMoreData];
}
@end
