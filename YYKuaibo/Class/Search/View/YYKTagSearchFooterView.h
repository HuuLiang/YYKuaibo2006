//
//  YYKTagSearchFooterView.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKTagSearchFooterView : UICollectionReusableView

@property (nonatomic) NSString *title;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic) CGAffineTransform imageTransform;
@property (nonatomic,copy) YYKAction tapAction;

@end
