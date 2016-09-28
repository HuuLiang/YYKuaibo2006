//
//  QJPayWithAliPay.h
//  QuanJingSDK
//
//  Created by WuXian on 15/10/30.
//  Copyright © 2015年 WuXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef QJPayWithAliPay_h
#define QJPayWithAliPay_h


@interface QJPayWithAliPay : NSObject

+ (void)sendAliPayMessage:(NSDictionary *)payInfo andAppScheme:(NSString *)aliAppScheme andResponseResultBlock:(void(^)(NSDictionary * ResponseResultDict))responseResultBlock;

+ (BOOL)handleOpenURL:(NSURL *)url;


@end

#endif