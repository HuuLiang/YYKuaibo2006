//
//  YYKInputTextViewController.h
//  YuePaoBa
//
//  Created by Sean Yue on 15/12/24.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

typedef BOOL (^YYKInputTextCompletionHandler)(id sender, NSString *text);
typedef BOOL (^YYKInputTextChangeHandler)(id sender, NSString *text);

@interface YYKInputTextViewController : YYKBaseViewController

@property (nonatomic) NSUInteger limitedTextLength;
@property (nonatomic) NSString *placeholder;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *completeButtonTitle;

@property (nonatomic,copy) YYKInputTextCompletionHandler completionHandler;
@property (nonatomic,copy) YYKInputTextChangeHandler changeHandler;

@end
