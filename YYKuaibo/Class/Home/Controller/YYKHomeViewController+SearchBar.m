//
//  YYKHomeViewController+SearchBar.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/23.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController+SearchBar.h"
#import "YYKTagSearchViewController.h"
#import "YYKSearchResultViewController.h"
#import "YYKKeyword.h"

static const void *kYYKHomeSearchBarAssociatedKey = &kYYKHomeSearchBarAssociatedKey;
static const void *kYYKTagSearchVCAssociatedKey = &kYYKTagSearchVCAssociatedKey;
static const void *kYYKErrorMessageAssociatedKey = &kYYKErrorMessageAssociatedKey;

static NSString *const kNonVIPSearchKeywordError = @"只有VIP会员才能使用关键字搜索功能！";

@interface YYKHomeViewController () <UISearchBarDelegate,YYKTagSearchViewControllerDelegate>
@property (nonatomic) NSAttributedString *errorMessage;
@property (nonatomic,retain) YYKTagSearchViewController *tagVC;
@end

@implementation YYKHomeViewController (SearchBar)

- (UISearchBar *)searchBar {
    UISearchBar *searchBar = objc_getAssociatedObject(self, kYYKHomeSearchBarAssociatedKey);
    if (searchBar) {
        return searchBar;
    }
    
    searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"关键字搜索";
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.delegate = self;
    searchBar.tintColor = [UIColor whiteColor];
    searchBar.barTintColor = [UIColor whiteColor];
    
    const CGFloat fullBarWidth = CGRectGetWidth(self.navigationController.navigationBar.bounds);
    const CGFloat fullBarHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    
    const CGFloat searchBarX = 60;
    const CGFloat searchBarWidth = fullBarWidth - searchBarX - kLeftRightContentMarginSpacing;
    const CGFloat searchBarHeight = fullBarHeight * 0.8;
    const CGFloat searchBarY = (fullBarHeight - searchBarHeight)/2;
    searchBar.frame = CGRectMake(searchBarX, searchBarY, searchBarWidth, searchBarHeight);
    
    objc_setAssociatedObject(self, kYYKHomeSearchBarAssociatedKey, searchBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return searchBar;
}

- (NSAttributedString *)errorMessage {
    return objc_getAssociatedObject(self, kYYKErrorMessageAssociatedKey);
}

- (void)setErrorMessage:(NSAttributedString *)errorMessage {
    objc_setAssociatedObject(self, kYYKErrorMessageAssociatedKey, errorMessage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (YYKTagSearchViewController *)tagVC {
    YYKTagSearchViewController *tagVC = objc_getAssociatedObject(self, kYYKTagSearchVCAssociatedKey);
    if (tagVC) {
        return tagVC;
    }
    
    tagVC = [[YYKTagSearchViewController alloc] init];
    tagVC.delegate = self;
    objc_setAssociatedObject(self, kYYKTagSearchVCAssociatedKey, tagVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return tagVC;
}

- (void)searchKeyword:(YYKKeyword *)keyword {
    [self.searchBar resignFirstResponder];
    
    if (![YYKUtil isVIP] && !keyword.isTag) {
        @weakify(self);
        [UIAlertView bk_showAlertViewWithTitle:nil
                                       message:@"只有VIP会员才能使用关键字搜索功能\n按[确定]后付费成为VIP\n按[取消]后您还可以使用标签搜索"
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@[@"确定"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex)
        {
            @strongify(self);
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
                [self payForPayPointType:QBPayPointTypeVIP];
            }
        }];
        return ;
    }
    YYKSearchResultViewController *searchResultVC = [[YYKSearchResultViewController alloc] initWithKeyword:keyword];
    [self.navigationController pushViewController:searchResultVC animated:YES];
    
}

- (void)showTagSearchViewController:(BOOL)show animated:(BOOL)animated {
    if (show == [self.childViewControllers containsObject:self.tagVC]) {
        return ;
    }
    
    if (show == [self.view.subviews containsObject:self.tagVC.view]) {
        return ;
    }
    
    if (show) {
        [self addChildViewController:self.tagVC];
        
        self.tagVC.view.frame = self.view.bounds;
        if (animated) {
            self.tagVC.view.frame = CGRectOffset(self.tagVC.view.frame, 0, self.tagVC.view.frame.size.height);
        }
        [self.view addSubview:self.tagVC.view];
        [self.tagVC didMoveToParentViewController:self];
        
        if (animated) {
            [UIView animateWithDuration:0.25 /*delay:0 options:UIViewAnimationOptionCurveEaseOut*/ animations:^{
                self.tagVC.view.frame = CGRectOffset(self.tagVC.view.frame, 0, -self.tagVC.view.frame.size.height);
            }];
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                self.tagVC.view.frame = CGRectOffset(self.tagVC.view.frame, 0, self.tagVC.view.frame.size.height);
            } completion:^(BOOL finished) {
                [self.tagVC willMoveToParentViewController:nil];
                [self.tagVC.view removeFromSuperview];
                [self.tagVC removeFromParentViewController];
            }];
        } else {
            [self.tagVC willMoveToParentViewController:nil];
            [self.tagVC.view removeFromSuperview];
            [self.tagVC removeFromParentViewController];
        }
        
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [[YYKHudManager manager] showHudWithText:@"请输入关键字"];
        return ;
    }
    
    [self searchKeyword:[YYKKeyword keywordWithText:searchBar.text isTag:NO]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self showTagSearchViewController:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}
//
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [self showTagSearchViewController:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [self showTagSearchViewController:NO animated:YES];
//    if (self.resultVC.searchedKeyword.text.length > 0) {
//        searchBar.text = self.resultVC.searchedKeyword.text;
//        
//        if (self.errorMessage) {
//            [self showTagSearchViewControllerWithAnimated:NO];
//        } else {
//            [self showSearchResultViewController];
//        }
//    }
}

#pragma mark - YYKTagSearchViewControllerDelegate

- (void)tagSearchViewControllerDidScroll:(YYKTagSearchViewController *)tagSearchVC {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

- (void)tagSearchViewController:(YYKTagSearchViewController *)tagSearchVC didSelectKeyword:(YYKKeyword *)keyword {
    self.searchBar.text = keyword.text;
    [self searchKeyword:keyword];
}
@end
