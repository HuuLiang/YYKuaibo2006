//
//  YYKPaymentPopView.h
//  JQKuaibo
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKPaymentPopView : UITableView

@property (nonatomic) NSURL *headerImageURL;

//@property (nonatomic,retain) UIImage *headerImage;
@property (nonatomic,retain) UIImage *footerImage;
//@property (nonatomic,copy) JQKPaymentAction paymentAction;
@property (nonatomic,copy) YYKAction closeAction;
@property (nonatomic) NSNumber *showPrice;

- (void)addPaymentWithImage:(UIImage *)image title:(NSString *)title available:(BOOL)available action:(YYKAction)action;
- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width;

@end
