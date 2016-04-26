//
//  YYKMineVIPCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKMineVIPCell : UITableViewCell

@property (nonatomic) NSString *memberTitle;
@property (nonatomic,copy) YYKAction memberAction;
@property (nonatomic,retain) UIImage *vipImage;

@end
