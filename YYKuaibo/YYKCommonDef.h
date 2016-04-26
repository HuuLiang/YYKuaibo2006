//
//  YYKCommonDef.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#ifndef YYKCommonDef_h
#define YYKCommonDef_h

typedef NS_ENUM(NSUInteger, YYKPaymentType) {
    YYKPaymentTypeNone,
    YYKPaymentTypeAlipay = 1001,
    YYKPaymentTypeWeChatPay = 1008,
    YYKPaymentTypeIAppPay = 1009
};

typedef NS_ENUM(NSInteger, PAYRESULT)
{
    PAYRESULT_SUCCESS   = 0,
    PAYRESULT_FAIL      = 1,
    PAYRESULT_ABANDON   = 2,
    PAYRESULT_UNKNOWN   = 3
};

typedef NS_ENUM(NSUInteger, YYKPayPointType) {
    YYKPayPointTypeNone,
    YYKPayPointTypeVIP,
    YYKPayPointTypeSVIP
};
// DLog
#ifdef  DEBUG
#define DLog(fmt,...) {NSLog((@"%s [Line:%d]" fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);}
#else
#define DLog(...)
#endif

#define DefineLazyPropertyInitialization(propertyType, propertyName) \
-(propertyType *)propertyName { \
if (_##propertyName) { \
return _##propertyName; \
} \
_##propertyName = [[propertyType alloc] init]; \
return _##propertyName; \
}

#define kScreenHeight     [ [ UIScreen mainScreen ] bounds ].size.height
#define kScreenWidth      [ [ UIScreen mainScreen ] bounds ].size.width

#define kPaidNotificationName @"yykuaibo_paid_notification"
#define kDefaultDateFormat    @"yyyyMMddHHmmss"
#define kDefaultCollectionViewInteritemSpace  (3)

typedef void (^YYKAction)(id obj);
typedef void (^YYKCompletionHandler)(BOOL success, id obj);
#endif /* YYKCommonDef_h */
