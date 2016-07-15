//
//  YYKTagSearchViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@class YYKTagSearchViewController;
@class YYKKeyword;

@protocol YYKTagSearchViewControllerDelegate <NSObject>

@optional
- (void)tagSearchViewController:(YYKTagSearchViewController *)tagSearchVC didSelectKeyword:(YYKKeyword *)keyword;
- (NSAttributedString *)searchErrorMessageInTagSearchViewController:(YYKTagSearchViewController *)tagSearchVC;
- (void)tagSearchViewController:(YYKTagSearchViewController *)tagSearchVC didSelectErrorMessage:(NSString *)errorMessage;

@end

@interface YYKTagSearchViewController : YYKBaseViewController

@property (nonatomic,weak) id<YYKTagSearchViewControllerDelegate> delegate;

- (void)reloadData;

@end
