//
//  SPayUtil.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/12.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPayUtil : NSObject

+ (void)payWithPaymentInfo:(YYKPaymentInfo *)paymentInfo
         completionHandler:(YYKPaymentCompletionHandler)completionHandler;
+ (void)applicationWillEnterForeground;
+ (void)setup;

//+ (BOOL)application:(UIApplication *)application
//didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
//
//+ (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation;
//
//+ (BOOL)application:(UIApplication *)application
//      handleOpenURL:(NSURL *)url;
//
//+ (BOOL)application:(UIApplication *)app
//            openURL:(NSURL *)url
//            options:(NSDictionary<NSString*, id> *)options;

@end
