//
//  YYKHomeRankingCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKHomeRankingCell : UICollectionViewCell

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *title;
@property (nonatomic) NSAttributedString *attributedTitle;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) NSString *tagName;
@property (nonatomic) NSUInteger popularity;

+ (CGFloat)widthRelativeToHeight:(CGFloat)height withImageScale:(CGFloat)imageScale;

@end
