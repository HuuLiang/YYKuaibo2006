//
//  QBOrderInfo.h
//  Pods
//
//  Created by Sean Yue on 2016/12/7.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBOrderPayType) {
    QBOrderPayTypeNone,
    QBOrderPayTypeWeChatPay,
    QBOrderPayTypeAlipay,
    QBOrderPayTypeQQPay
};

@interface QBOrderInfo : NSObject

@property (nonatomic) NSString *orderId;
@property (nonatomic) NSUInteger orderPrice;  //以分为单位
@property (nonatomic) NSString *orderDescription;
@property (nonatomic) QBOrderPayType payType;

@property (nonatomic) NSString *createTime;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSUInteger payPointType;
@property (nonatomic) NSString *contact;
@property (nonatomic) NSString *reservedData;

@end
