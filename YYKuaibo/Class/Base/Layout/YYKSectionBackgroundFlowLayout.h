//
//  YYKSectionBackgroundFlowLayout.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const YYKElementKindSectionBackground;

@interface YYKSectionBackgroundFlowLayout : UICollectionViewFlowLayout

@end

@protocol YYKSectionBackgroundFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional

- (BOOL)collectionView:(UICollectionView *)collectionView
                layout:(UICollectionViewLayout *)collectionViewLayout
shouldDisplaySectionBackgroundInSection:(NSUInteger)section;

@end
