//
//  YYKWeeklyRankingRowCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKWeeklyRankingRowCellItem : NSObject

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) NSString *tag;
@property (nonatomic) NSUInteger popularity;
@end

@interface YYKWeeklyRankingRowCell : UICollectionViewCell

@property (nonatomic,retain) NSArray<YYKWeeklyRankingRowCellItem *> *items;
@property (nonatomic,copy) YYKSelectionAction selectionAction;

@end
