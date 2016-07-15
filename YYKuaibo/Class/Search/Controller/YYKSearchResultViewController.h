//
//  YYKSearchResultViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@class YYKKeyword;

@interface YYKSearchResultViewController : YYKBaseViewController

@property (nonatomic,retain) YYKKeyword *searchedKeyword;

//@property (nonatomic,readonly) NSString *searchedKeywords;
//@property (nonatomic,readonly) BOOL isTagKeyword;

- (void)searchKeyword:(YYKKeyword *)keyword withCompletionHandler:(YYKCompletionHandler)completionHandler;

@end
