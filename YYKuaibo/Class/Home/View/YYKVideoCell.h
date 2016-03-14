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
@property (nonatomic) NSString *title;
@property (nonatomic) BOOL showPlayIcon;

+ (CGFloat)footerViewHeight;

@end
