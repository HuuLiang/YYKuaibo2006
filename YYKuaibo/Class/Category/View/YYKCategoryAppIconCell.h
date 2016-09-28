//
//  YYKCategoryAppIconCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKCategoryAppIconCell : UICollectionViewCell

@property (nonatomic) NSString *title;
@property (nonatomic) NSURL *imageURL;

+ (CGFloat)cellHeightRelativeToWidth:(CGFloat)width;

@end
