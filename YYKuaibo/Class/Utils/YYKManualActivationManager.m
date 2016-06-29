//
//  YYKManualActivationManager.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKManualActivationManager.h"
#import "YYKOrderQueryModel.h" 
#import "YYKPaymentViewController.h"

@interface YYKManualActivationManager ()
@property (nonatomic,retain) YYKOrderQueryModel *orderQueryModel;
@end

@implementation YYKManualActivationManager

DefineLazyPropertyInitialization(YYKOrderQueryModel, orderQueryModel)

+ (instancetype)sharedManager {
    static YYKManualActivationManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)doActivation {
    if ([YYKUtil isAllVIPs]) {
        return ;
    }
    
    NSArray<YYKPaymentInfo *> *paymentInfos = [YYKUtil allUnsuccessfulPaymentInfos];
    if ([YYKUtil isVIP] && ![YYKUtil isSVIP]) {
        paymentInfos = [paymentInfos bk_select:^BOOL(YYKPaymentInfo *paymentInfo) {
            return paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP;
        }];
    }
    
    NSMutableString *orders = [NSMutableString string];
    [paymentInfos enumerateObjectsUsingBlock:^(YYKPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.orderId.length > 0) {
            [orders appendString:obj.orderId];
            
            if (idx != paymentInfos.count-1) {
                [orders appendString:@"|"];
            }
        }
    }];
    
    if (orders.length == 0) {
        [[YYKHudManager manager] showHudWithText:@"未找到支付成功的订单"];
        return ;
    }
    
    [[UIApplication sharedApplication].keyWindow beginLoading];
    [self.orderQueryModel queryOrder:orders withCompletionHandler:^(BOOL success, id obj) {
        [[UIApplication sharedApplication].keyWindow endLoading];
        
        if (success) {
            [[YYKHudManager manager] showHudWithText:@"激活成功"];
            //[[YYKPaymentViewController sharedPaymentVC] notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:paymentInfo];
        } else {
            [[YYKHudManager manager] showHudWithText:@"未找到支付成功的订单"];
        }
    }];
}

@end
