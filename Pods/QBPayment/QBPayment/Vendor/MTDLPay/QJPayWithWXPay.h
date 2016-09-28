//
//  QJPayWithWXPay.h
//  QJPayWithWXPay
//
//  Created by WuXian on 16/5/20.
//  Copyright © 2016年 WuXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#ifndef QJPayWithWXPay_h
#define QJPayWithWXPay_h

@interface QJPayWithWXPay : NSObject

+ (void)sendWeChatMessage:(NSString *)orderInfo andAppScheme:(NSString *)weChatAppScheme resPonseResult:(void(^)(int statusCode))responseResultBlock;


+(BOOL) handleOpenURL:(NSURL *) url delegate:(id<WXApiDelegate>) delegate;




@end
#endif