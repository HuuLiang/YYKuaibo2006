//
//  YYKCategoryRoundImageCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKCategoryRoundImageCell : UICollectionViewCell

@property (nonatomic) NSString *title;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSUInteger popularity;

+ (CGFloat)cellHeightRelativeToWidth:(CGFloat)width;

@end
