//
//  QBPaymentConfigModel.h
//  QBuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "QBPaymentURLRequest.h"
#import "QBDefines.h"

@interface QBPaymentConfigModel : QBPaymentURLRequest

@property (nonatomic,readonly) BOOL loaded;
@property (nonatomic) BOOL isTest;

- (BOOL)fetchConfigWithCompletionHandler:(QBCompletionHandler)handler;

@end
