//
//  YYKHomeViewController+CollectionViewModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/23.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController.h"

@interface YYKHomeViewController (CollectionViewModel)

@property (nonatomic,retain,readonly) UICollectionView *layoutCollectionView;

- (void)reloadTrialSection;

@end
