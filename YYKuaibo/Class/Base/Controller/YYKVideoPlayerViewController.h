//
//  YYKVideoPlayerViewController.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBaseViewController.h"

@interface YYKVideoPlayerViewController : YYKBaseViewController

@property (nonatomic,retain,readonly) YYKProgram *video;
@property (nonatomic,readonly) NSUInteger videoLocation;
@property (nonatomic,retain,readonly) YYKChannel *channel;
@property (nonatomic) BOOL shouldPopupPaymentIfNotPaid;

- (instancetype)initWithVideo:(YYKProgram *)video videoLocation:(NSUInteger)videoLocation channel:(YYKChannel *)channel;

@end
