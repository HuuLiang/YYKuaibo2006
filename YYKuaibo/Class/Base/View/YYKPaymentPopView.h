//
//  YYKPaymentPopView.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^YYKPaymentAction)(id sender);

@interface YYKPaymentPopView : UITableView

@property (nonatomic,retain) UIImage *headerImage;
@property (nonatomic,retain) UIImage *footerImage;
//@property (nonatomic,copy) YYKPaymentAction paymentAction;
@property (nonatomic,copy) YYKPaymentAction closeAction;
@property (nonatomic) NSNumber *showPrice;

- (void)addPaymentWithImage:(UIImage *)image title:(NSString *)title available:(BOOL)available action:(YYKPaymentAction)action;
- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width;

@end
