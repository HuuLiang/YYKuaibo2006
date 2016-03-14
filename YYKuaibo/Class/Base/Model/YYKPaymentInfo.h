//
//  YYKPaymentInfo.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/17.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YYKPaymentStatus) {
    YYKPaymentStatusUnknown,
    YYKPaymentStatusPaying,
    YYKPaymentStatusNotProcessed,
    YYKPaymentStatusProcessed
};

@interface YYKPaymentInfo : NSObject

@property (nonatomic) NSString *paymentId;
@property (nonatomic) NSString *orderId;
@property (nonatomic) NSNumber *orderPrice;
@property (nonatomic) NSNumber *contentId;
@property (nonatomic) NSNumber *contentType;
@property (nonatomic) NSNumber *payPointType;
@property (nonatomic) NSString *paymentTime;
@property (nonatomic) NSNumber *paymentType;
@property (nonatomic) NSNumber *paymentResult;
@property (nonatomic) NSNumber *paymentStatus;

+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment;
- (void)save;

@end
