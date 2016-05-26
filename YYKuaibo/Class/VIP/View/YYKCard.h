//
//  YYKCard.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/21.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKCard : UIView

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) BOOL lightedDiamond;

@end
