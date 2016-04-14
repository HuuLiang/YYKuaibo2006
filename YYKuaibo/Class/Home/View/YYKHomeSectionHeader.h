//
//  YYKHomeSectionHeader.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKHomeSectionHeader : UICollectionReusableView

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) UIOffset contentSizeOffset;

@property (nonatomic,retain,readonly) UIView *contentView;
@end
