//
//  YYKHomeTrialCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKHomeTrialCell : UICollectionViewCell

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *title;

+ (CGFloat)heightRelativeToWidth:(CGFloat)width withImageScale:(CGFloat)imageScale;

@end
