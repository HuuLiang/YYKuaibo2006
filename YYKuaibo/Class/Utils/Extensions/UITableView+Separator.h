//
//  UITableView+Separator.h
//  YuePaoBa
//
//  Created by Sean Yue on 15/10/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UITableViewSeparatorDelegate <UITableViewDelegate>

@optional
- (BOOL)tableView:(UITableView *)tableView hasSeparatorBetweenIndexPath:(NSIndexPath *)lowerIndexPath andIndexPath:(NSIndexPath *)upperIndexPath;

- (BOOL)tableView:(UITableView *)tableView hasBorderInSection:(NSUInteger)section;

@end

@interface UITableView (Separator)

@property (nonatomic) BOOL hasRowSeparator;
@property (nonatomic) BOOL hasSectionBorder;

@end
