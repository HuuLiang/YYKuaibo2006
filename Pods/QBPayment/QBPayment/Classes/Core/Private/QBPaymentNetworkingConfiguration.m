//
//  QBPaymentNetworkingConfiguration.m
//  Pods
//
//  Created by Sean Yue on 16/9/13.
//
//

#import "QBPaymentNetworkingConfiguration.h"

@implementation QBPaymentNetworkingConfiguration

+ (instancetype)defaultConfiguration {
    static QBPaymentNetworkingConfiguration *_paymentConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _paymentConfiguration = [[self alloc] init];
    });
    return _paymentConfiguration;
}

- (BOOL)logEnabled {
    return YES;
}
    
@end
