//
//  ZWXPaySDK_1.h
//  TestDemo
//
//  Created by ZJ on 16/12/9.
//  Copyright © 2016年 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController,ZWXPayModel, ZWXPayRespObject;

typedef void(^WXzfBlock)(ZWXPayRespObject *respObject);

@interface ZWXPayRespObject : NSObject <NSCopying>

/**
 *  支付结果，支付成功返回 YES, 其它返回 NO
 */
@property (nonatomic, assign) BOOL status;

/**
 *  支付状态的描述信息, 为支付状态为NO时会显示失败的描述
 */
@property (nonatomic, copy) NSString *returnMsg;


@end


@interface ZWXPaySDK_1 : NSObject

//微信支付
- (void)tbatWithZWXPayModel:(ZWXPayModel *)payModel ViewController:(UIViewController *)viewController complete:(void(^)(ZWXPayRespObject *respObject))complete;

@end


@interface BlockManager : NSObject

@property (nonatomic, copy) WXzfBlock wxzfBlock;

+ (instancetype)shareManager;

@end

