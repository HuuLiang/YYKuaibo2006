//
//  YYKManualActivationManager.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKManualActivationManager.h"
#import "YYKPaymentViewController.h"

@interface YYKManualActivationManager ()
@end

@implementation YYKManualActivationManager

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
        [UIAlertView bk_showAlertViewWithTitle:@"您已经购买了全部VIP，无需再激活！" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
        return ;
    }
    
    NSArray<YYKPaymentInfo *> *paymentInfos = [YYKUtil allUnsuccessfulPaymentInfos];
    if ([YYKUtil isVIP] && ![YYKUtil isSVIP]) {
        paymentInfos = [paymentInfos bk_select:^BOOL(YYKPaymentInfo *paymentInfo) {
            return paymentInfo.payPointType == QBPayPointTypeSVIP;
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
        [UIAlertView bk_showAlertViewWithTitle:@"未找到支付成功的订单" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
        return ;
    }
    
    [[UIApplication sharedApplication].keyWindow beginLoading];
    [[QBPaymentManager sharedManager] queryOrder:orders withCompletionHandler:^(BOOL success, id obj) {
        [[UIApplication sharedApplication].keyWindow endLoading];
        
        if (success) {
            if (![obj isKindOfClass:[NSString class]]) {
                [UIAlertView bk_showAlertViewWithTitle:@"无法解析激活数据" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
                return ;
            }
            
            NSArray<NSString *> *paidOrders = [obj componentsSeparatedByString:@"|"];
            NSArray<YYKPaymentInfo *> *paidPaymentInfos = [paymentInfos bk_select:^BOOL(YYKPaymentInfo *paymentInfo) {
                return [paidOrders containsObject:paymentInfo.orderId];
            }];
            
            YYKPaymentInfo *paidPaymentInfo = [paidPaymentInfos bk_match:^BOOL(YYKPaymentInfo *paymentInfo) {
                return paymentInfo.payPointType == QBPayPointTypeSVIP;
            }];
            
            if (!paidPaymentInfo) {
                paidPaymentInfo = [paidPaymentInfos bk_match:^BOOL(YYKPaymentInfo *paymentInfo) {
                    return paymentInfo.payPointType == QBPayPointTypeVIP;
                }];
            }
            
            if (paidPaymentInfo) {
                [UIAlertView bk_showAlertViewWithTitle:@"激活成功" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
                [[YYKPaymentViewController sharedPaymentVC] notifyPaymentResult:QBPayResultSuccess withPaymentInfo:paidPaymentInfo];
            } else {
                [UIAlertView bk_showAlertViewWithTitle:@"未找到支付成功的订单" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
            }
            
        } else {
            [UIAlertView bk_showAlertViewWithTitle:@"未找到支付成功的订单" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
        }
    }];
}

@end
