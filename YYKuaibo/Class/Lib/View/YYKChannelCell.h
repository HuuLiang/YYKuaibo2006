//
//  YYKChannelCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKChannelCell : UITableViewCell

@property (nonatomic) NSURL *imageURL;
@property (nonatomic,retain) UIImage *placeholderImage;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) NSUInteger popularity;

@end
