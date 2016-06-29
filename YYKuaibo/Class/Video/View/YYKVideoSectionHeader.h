//
//  YYKVideoSectionHeader.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKVideoSectionHeader : UICollectionReusableView

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) UIColor *iconColor;
@property (nonatomic) UIColor *titleColor;
@property (nonatomic) UIColor *accessoryTintColor;
@property (nonatomic) YYKAction accessoryAction;
@property (nonatomic) BOOL accessoryHidden;

@property (nonatomic,retain,readonly) UIView *contentView;
@end
