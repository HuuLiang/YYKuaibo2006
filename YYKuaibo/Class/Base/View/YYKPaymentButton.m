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
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    const CGFloat height = CGRectGetHeight(contentRect) * 0.8;
    return CGRectMake(5, (contentRect.size.height - height)/2, height, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [self imageRectForContentRect:contentRect];
    const CGFloat height = imageRect.size.height;
    const CGFloat x = CGRectGetMaxX(imageRect)+15;
    return CGRectMake(x, (contentRect.size.height - height)/2, contentRect.size.width-x-15, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}
@end
