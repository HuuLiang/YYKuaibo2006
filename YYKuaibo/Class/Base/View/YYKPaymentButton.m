//
//  YYKPaymentButton.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPaymentButton.h"

@implementation YYKPaymentButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.font = kBoldMediumFont;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    const CGFloat height = CGRectGetHeight(contentRect) * 0.6;
    return CGRectMake(8, (contentRect.size.height - height)/2, height, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [self imageRectForContentRect:contentRect];
//    const CGFloat height = imageRect.size.height;
    const CGFloat x = CGRectGetMaxX(imageRect)+5;
    return CGRectMake(x, 0, contentRect.size.width-x-5, contentRect.size.height);
}
@end
