//
//  QBPaymentDefines.h
//  Pods
//
//  Created by Sean Yue on 16/9/13.
//
//

#ifndef QBPaymentDefines_h
#define QBPaymentDefines_h

typedef NS_ENUM(NSUInteger, QBPayType) {
    QBPayTypeNone,
    QBPayTypeAlipay = 1001,
    QBPayTypeWeChatPay = 1008,
    QBPayTypeIAppPay = 1009, //爱贝支付
    QBPayTypeVIAPay = 1010, //首游时空
    QBPayTypeSPay = 1012, //威富通
    QBPayTypeHTPay = 1015, //海豚支付
    QBPayTypeMingPay = 1018, //明鹏支付
    QBPayTypeDXTXPay = 1019, //盾行天下
    QBPayTypeWeiYingPay = 1022, //微赢支付
};

typedef NSUInteger QBPayPointType;

//typedef NS_ENUM(NSUInteger, QBPayPointType) {
//    QBPayPointTypeNone,
//    QBPayPointTypeVIP,
//    QBPayPointTypeSVIP
//};

typedef NS_ENUM(NSUInteger, QBPaySubType) {
    QBPaySubTypeNone = 0,
    QBPaySubTypeWeChat = 1 << 0,
    QBPaySubTypeAlipay = 1 << 1,
    QBPaySubTypeUPPay = 1 << 2,
    QBPaySubTypeQQ = 1 << 3
};

typedef NS_ENUM(NSInteger, QBPayResult)
{
    QBPayResultSuccess   = 0,
    QBPayResultFailure   = 1,
    QBPayResultCancelled = 2,
    QBPayResultUnknown   = 3
};

typedef NS_ENUM(NSUInteger, QBPayStatus) {
    QBPayStatusUnknown,
    QBPayStatusPaying,
    QBPayStatusNotProcessed,
    QBPayStatusProcessed
};

@class QBPaymentInfo;
typedef void (^QBPaymentCompletionHandler)(QBPayResult payResult, QBPaymentInfo *paymentInfo);

#endif /* QBPaymentDefines_h */
