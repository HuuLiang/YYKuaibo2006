//
//  YYKVIPVideoCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKVIPVideoCell : UICollectionViewCell

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *title;
@property (nonatomic,retain) UIImage *placeholderImage;

+ (CGFloat)heightRelativeToWidth:(CGFloat)width withImageScale:(CGFloat)imageScale;

@end
