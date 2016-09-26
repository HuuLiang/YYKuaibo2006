//
//  YYKSearchViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSearchViewController.h"
#import "YYKTagSearchViewController.h"
#import "YYKSearchResultViewController.h"
#import "YYKKeyword.h"

static NSString *const kNonVIPSearchKeywordError = @"只有VIP会员才能使用关键字搜索功能！";

@interface YYKSearchViewController () <UISearchBarDelegate,YYKTagSearchViewControllerDelegate>
{
    YYKTagSearchViewController *_tagSearchVC;
}
@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) YYKTagSearchViewController *tagVC;
@property (nonatomic,retain) YYKSearchResultViewController *resultVC;
@property (nonatomic) NSAttributedString *errorMessage;
@end

@implementation YYKSearchViewController

DefineLazyPropertyInitialization(YYKTagSearchViewController, tagVC)
DefineLazyPropertyInitialization(YYKSearchResultViewController, resultVC)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = nil;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationController.navigationBar addSubview:self.searchBar];
    self.tagVC.delegate = self;
    
    [self showTagSearchViewControllerWithAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
}

- (UISearchBar *)searchBar {
    if (_searchBar) {
        return _searchBar;
    }
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = @"关键字搜索";
    _searchBar.searchBarStyle = UISearchBarStyleDefault;
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor whiteColor];
    _searchBar.barTintColor = [UIColor whiteColor];
    
    const CGFloat fullBarWidth = CGRectGetWidth(self.navigationController.navigationBar.bounds);
    const CGFloat fullBarHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    
    const CGFloat searchBarWidth = fullBarWidth * 0.9;
    const CGFloat searchBarHeight = fullBarHeight * 0.8;
    const CGFloat searchBarX = (fullBarWidth - searchBarWidth)/2;
    const CGFloat searchBarY = (fullBarHeight - searchBarHeight)/2;
    _searchBar.frame = CGRectMake(searchBarX, searchBarY, searchBarWidth, searchBarHeight);
    
    return _searchBar;
}

- (void)searchKeyword:(YYKKeyword *)keyword {
    [_searchBar resignFirstResponder];
    
    if ([YYKUtil isVIP] || keyword.isTag) {
        [self showSearchResultViewController];
        
        @weakify(self);
        [self.resultVC searchKeyword:keyword withCompletionHandler:^(BOOL success, id obj) {
            @strongify(self);
            if (!self) {
                return ;
            }
            
            if (success) {
                self.errorMessage = nil;
            } else {
                NSError *error = obj;
                
                NSString *errorMessage;
                if (!error) {
                    errorMessage = @"您搜索的内容未能找到！";
                } else if (error.code == kSearchNetworkErrorCode) {
                    errorMessage = @"由于网络问题，您搜索的内容无法显示！";
                } else if (error.code == kSearchLogicErrorCode) {
                    errorMessage = @"由于业务逻辑问题，您搜索的内容无法显示！";
                } else {
                    errorMessage = @"搜索的过程中出现了未知的错误！";
                }
                
                NSAttributedString *firstLineString = [[NSAttributedString alloc] initWithString:errorMessage attributes:@{NSFontAttributeName:kMediumFont}];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"\n请选择以下关键字或者点击此处刷新结果！" attributes:@{NSFontAttributeName:kMediumFont}];
                [attrString addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor], NSUnderlineStyleAttributeName:@1} range:[attrString.string rangeOfString:@"点击此处"]];
                [attrString insertAttributedString:firstLineString atIndex:0];
                self.errorMessage = attrString;
                
                [self showTagSearchViewControllerWithAnimated:NO];
            }
        }];
    } else {
        NSAttributedString *firstLineString = [[NSAttributedString alloc] initWithString:kNonVIPSearchKeywordError attributes:@{NSFontAttributeName:kMediumFont}];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"\n请选择以下标签搜索或者点击此处付费成为VIP会员！" attributes:@{NSFontAttributeName:kMediumFont}];
        [attrString addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor], NSUnderlineStyleAttributeName:@1} range:[attrString.string rangeOfString:@"点击此处"]];
        [attrString insertAttributedString:firstLineString atIndex:0];
        self.errorMessage = attrString;
        [self.tagVC reloadData];
    }
    
}

- (void)showTagSearchViewControllerWithAnimated:(BOOL)animated {
    if ([self.childViewControllers containsObject:self.tagVC]) {
        return ;
    }
    
    if ([self.view.subviews containsObject:self.tagVC.view]) {
        return ;
    }
    
    [self addChildViewController:self.tagVC];
    
    self.tagVC.view.frame = self.view.bounds;
    if (animated) {
        self.tagVC.view.frame = CGRectOffset(self.tagVC.view.frame, 0, self.tagVC.view.frame.size.height);
    }
    [self.view addSubview:self.tagVC.view];
    [self.tagVC didMoveToParentViewController:self];
    
    
    void (^HideSearchResults)(void) = ^{
        if ([self.childViewControllers containsObject:self.resultVC]) {
            [self.resultVC willMoveToParentViewController:nil];
            [self.resultVC removeFromParentViewController];
            [self.resultVC.view removeFromSuperview];
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 /*delay:0 options:UIViewAnimationOptionCurveEaseOut*/ animations:^{
            self.tagVC.view.frame = CGRectOffset(self.tagVC.view.frame, 0, -self.tagVC.view.frame.size.height);
        } completion:^(BOOL finished) {
            HideSearchResults();
        }];
    } else {
        HideSearchResults();
    }
}

- (void)showSearchResultViewController {
    if ([self.childViewControllers containsObject:self.resultVC]) {
        return ;
    }
    
    if ([self.view.subviews containsObject:self.resultVC.view]) {
        return ;
    }
    
    [self addChildViewController:self.resultVC];
    self.resultVC.view.frame = self.view.bounds;
    [self.view addSubview:self.resultVC.view];
    [self.resultVC didMoveToParentViewController:self];
    
    if ([self.childViewControllers containsObject:self.tagVC]) {
        [self.tagVC willMoveToParentViewController:nil];
        [self.tagVC removeFromParentViewController];
        [self.tagVC.view removeFromSuperview];
//        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.tagVC.view.frame = CGRectOffset(self.tagVC.view.frame, 0, CGRectGetHeight(self.tagVC.view.frame));
//        } completion:^(BOOL finished) {
//            [self.tagVC willMoveToParentViewController:nil];
//            [self.tagVC removeFromParentViewController];
//            [self.tagVC.view removeFromSuperview];
//        }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchBar.hidden = YES;
}

- (void)onPaidNotification {
    if ([self.errorMessage.string rangeOfString:kNonVIPSearchKeywordError].location == 0) {
        self.errorMessage = nil;
        [self.tagVC reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self showTagSearchViewControllerWithAnimated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (self.resultVC.searchedKeyword.text.length > 0) {
        searchBar.text = self.resultVC.searchedKeyword.text;
        
        if (self.errorMessage) {
            [self showTagSearchViewControllerWithAnimated:NO];
        } else {
            [self showSearchResultViewController];
        }
    }
}
@end
