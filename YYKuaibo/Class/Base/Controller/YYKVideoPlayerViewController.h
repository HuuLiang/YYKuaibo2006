//
//  YYKVideoPlayerViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@interface YYKVideoPlayerViewController : YYKBaseViewController

@property (nonatomic,retain,readonly) YYKVideo *video;
@property (nonatomic) BOOL shouldPopupPaymentIfNotPaid;

- (instancetype)initWithVideo:(YYKVideo *)video;

@end
