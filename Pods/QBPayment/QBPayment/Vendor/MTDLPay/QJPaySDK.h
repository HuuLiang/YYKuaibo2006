//
//  QJPaySDK.h
//  QJPaySDK
//
//  Created by WuXian on 16/5/20.
//  Copyright © 2016年 WuXian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol QJPayManagerDelegate <NSObject>

/**
 支付返回结果回调
 response：应答码:
 0：成功;
 -1：失败;
 1：用户取消;
 */
- (void)QJPayResponseResult:(int)response;




@end



@interface QJPaySDK : NSObject



+ (void)QJPayStart:(NSDictionary *)param AppScheme:(NSString *)scheme appKey:(NSString *)appKey andCurrentViewController:(UIViewController *)vc andDelegate:(id<QJPayManagerDelegate>)delegate Flag:(int)flag;

+(NSString*)PAY_WEIXIN;
+(NSString*)PAY_BAIDU;
+(NSString*)PAY_APLIPAY;
+(NSString*)PAY_PONITCART;

+(NSString*)WETCHAR;





+ (BOOL)handleOpenURL:(NSURL *)url;

+ (BOOL)handleOpenWeChatURL:(NSURL *)url;


@end
