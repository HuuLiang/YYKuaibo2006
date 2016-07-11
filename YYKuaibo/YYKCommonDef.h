//
//  YYKCommonDef.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#ifndef YYKCommonDef_h
#define YYKCommonDef_h

typedef NS_ENUM(NSUInteger, YYKDeviceType) {
    YYKDeviceTypeUnknown,
    YYKDeviceType_iPhone4,
    YYKDeviceType_iPhone4S,
    YYKDeviceType_iPhone5,
    YYKDeviceType_iPhone5C,
    YYKDeviceType_iPhone5S,
    YYKDeviceType_iPhone6,
    YYKDeviceType_iPhone6P,
    YYKDeviceType_iPhone6S,
    YYKDeviceType_iPhone6SP,
    YYKDeviceType_iPhoneSE,
    YYKDeviceType_iPad = 100
};

typedef NS_ENUM(NSUInteger, YYKPaymentType) {
    YYKPaymentTypeNone,
    YYKPaymentTypeAlipay = 1001,
    YYKPaymentTypeWeChatPay = 1008,
    YYKPaymentTypeIAppPay = 1009, //爱贝支付
    YYKPaymentTypeVIAPay = 1010, //首游时空
    YYKPaymentTypeSPay = 1012, //威富通
    YYKPaymentTypeHTPay = 1015 //海豚支付
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

typedef NS_ENUM(NSUInteger, YYKVideoSpec) {
    YYKVideoSpecNone,
    YYKVideoSpecHot,
    YYKVideoSpecNew,
    YYKVideoSpecHD,
    YYKVideoSpecFree,
    YYKVideoSpecVIP
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

#define SafelyCallBlock(block,...) \
    if (block) block(__VA_ARGS__);

#define SafelyCallBlockAndRelease(block,...) \
    if (block) { block(__VA_ARGS__); block = nil;};


#define kScreenHeight     [ [ UIScreen mainScreen ] bounds ].size.height
#define kScreenWidth      [ [ UIScreen mainScreen ] bounds ].size.width

#define kPaidNotificationName @"yykuaibo_paid_notification"
#define kDefaultDateFormat    @"yyyyMMddHHmmss"
#define kDefaultCollectionViewInteritemSpace  (5)
#define kThemeColor [UIColor darkPink]

static NSString *const kChannelPersistenceSpace = @"yykuaibo_1";
static NSString *const kChannelProgramPersistenceSpace = @"yykuaibo_2";
static NSString *const kHomePersistenceSpace = @"yykuaibo_3";
static NSString *const kVIPPersistenceSpace = @"yykuaibo_4";

static NSString *const kPersistenceCryptPassword = @"#%Q%$#afaf3134134";
static NSString *const kChannelPrimaryKey = @"columnId";
static NSString *const kSVIPText = @"黑钻VIP";
static NSString *const kSVIPShortText = @"黑钻";

@class YYKPaymentInfo;
typedef void (^YYKAction)(id obj);
typedef void (^YYKCompletionHandler)(BOOL success, id obj);
typedef void (^YYKPaymentCompletionHandler)(PAYRESULT payResult, YYKPaymentInfo *paymentInfo);

FOUNDATION_STATIC_INLINE NSString * YYKIntegralPrice(const CGFloat price) {
    if ((unsigned long)(price * 100.) % 100==0) {
        return [NSString stringWithFormat:@"%ld", (unsigned long)price];
    } else {
        return [NSString stringWithFormat:@"%.2f", price];
    }
}
#endif /* YYKCommonDef_h */
