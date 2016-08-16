//
//  YYKCard.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/21.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKCard : UIView

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic,retain) UIImage *iconImage;
@property (nonatomic,retain) UIImage *backgroundImage;

+ (CGSize)sizeRelativeToWidth:(CGFloat)width imageScale:(CGFloat)imageScale;

@end
