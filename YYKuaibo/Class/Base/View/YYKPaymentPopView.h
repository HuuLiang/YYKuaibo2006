//
//  YYKPaymentPopView.h
//  JQKuaibo
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKPaymentPopView : UITableView

//@property (nonatomic) NSURL *headerImageURL;

//@property (nonatomic,retain) UIImage *titleImage;
@property (nonatomic,copy) YYKAction closeAction;
@property (nonatomic,copy) YYKAction footerAction;
@property (nonatomic) YYKPayPointType payPointType;

- (void)addPaymentWithImage:(UIImage *)image
                      title:(NSString *)title
            backgroundColor:(UIColor *)backgroundColor
                     action:(YYKAction)action;

- (void)addPaymentWithImage:(UIImage *)image
                      title:(NSString *)title
                   subtitle:(NSString *)subtitle
            backgroundColor:(UIColor *)backgroundColor
                     action:(YYKAction)action;

- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width;

@end
