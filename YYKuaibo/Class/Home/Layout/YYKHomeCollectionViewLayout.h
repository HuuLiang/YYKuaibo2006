//
//  YYKHomeCollectionViewLayout.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YYKHomeSection) {
    YYKHomeSectionBanner,
    YYKHomeSectionTrial,
    YYKHomeSectionChannelOffset
};

@interface YYKHomeCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGFloat interItemSpacing;

@end
