//
//  MLYPayManager.h
//  Pods
//
//  Created by Sean Yue on 2017/1/13.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface MLYPayManager : NSObject

@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *channelId;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler;
- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
