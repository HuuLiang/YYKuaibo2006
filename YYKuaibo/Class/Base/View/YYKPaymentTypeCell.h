//
//  YYKPaymentTypeCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYKPaymentButton;

@interface YYKPaymentTypeCell : UICollectionViewCell

@property (nonatomic,retain,readonly) YYKPaymentButton *paymentButton;
@property (nonatomic,copy) YYKAction paymentAction;

@end
