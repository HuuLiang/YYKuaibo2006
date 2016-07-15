//
//  YYKPayPointTypeCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/31.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKPayPointTypeCell : UITableViewCell

@property (nonatomic,retain,readonly) UILabel *titleLabel;
@property (nonatomic,retain,readonly) UILabel *subtitleLabel;

//@property (nonatomic) CGFloat currentPrice;
//@property (nonatomic) CGFloat originalPrice;
@property (nonatomic) BOOL showOnlyTitle;
@property (nonatomic) NSAttributedString *placeholder;

@end
