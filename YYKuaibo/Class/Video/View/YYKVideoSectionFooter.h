//
//  YYKVideoSectionFooter.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKVideoSectionFooter : UICollectionReusableView

@property (nonatomic) NSString *title;
@property (nonatomic,copy) YYKAction tapAction;
@property (nonatomic) BOOL showSeparator;
@property (nonatomic) UIColor *titleColor;

@end
