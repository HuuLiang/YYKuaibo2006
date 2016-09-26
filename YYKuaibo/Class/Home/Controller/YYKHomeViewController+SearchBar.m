//
//  YYKHomeViewController+SearchBar.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/23.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController+SearchBar.h"

#import "YYKKeyword.h"

static const void *kYYKHomeSearchBarAssociatedKey = &kYYKHomeSearchBarAssociatedKey;

@interface YYKHomeViewController () <UISearchBarDelegate>

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

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [[YYKHudManager manager] showHudWithText:@"请输入关键字"];
        return ;
    }
    
//    [self searchKeyword:[YYKKeyword keywordWithText:searchBar.text isTag:NO]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    [self showTagSearchViewControllerWithAnimated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}
//
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
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

@end
