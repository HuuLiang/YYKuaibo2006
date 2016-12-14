//
//  HTPayManager.h
//  QBuaibo
//
//  Created by Sean Yue on 16/9/1.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBDefines.h"

@class QBPaymentInfo;

@interface HTPayManager : NSObject

@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
//@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *payType;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)sharedManager;
- (void)setup;
- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBCompletionHandler)completionHandler;
@end
