//
//  YYKVideoCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKVideoCell : UICollectionViewCell

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *tagText;
@property (nonatomic) UIColor *tagBackgroundColor;
@property (nonatomic) NSUInteger popularity;

+ (CGFloat)heightRelativeToWidth:(CGFloat)width withScale:(CGFloat)scale;

@end
