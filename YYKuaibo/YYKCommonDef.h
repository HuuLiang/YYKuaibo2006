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
//    YYKPaymentTypeSPay = 1012, //威富通
//    YYKPaymentTypeHTPay = 1015 //海豚支付
    YYKPaymentTypeMingPay = 1018
};

typedef NS_ENUM(NSUInteger, YYKSubPayType) {
    YYKSubPayTypeNone = 0,
    YYKSubPayTypeWeChat = 1 << 0,
    YYKSubPayTypeAlipay = 1 << 1,
    YYKSubPayUPPay = 1 << 2,
    YYKSubPayTypeQQ = 1 << 3
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

// Search Error Definitions
extern NSString *const kSearchErrorDomain;
extern const NSInteger kSearchParameterErrorCode;
extern const NSInteger kSearchLogicErrorCode;
extern const NSInteger kSearchNetworkErrorCode;
extern const NSInteger kSearchUnknownErrorCode;

extern NSString *const kSearchErrorMessageKey;

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
#define kThemeColor [UIColor colorWithHexString:@"#ab47bc"]

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
typedef void (^YYKSelectionAction)(NSUInteger index, id obj);

FOUNDATION_STATIC_INLINE NSString * YYKIntegralPrice(const CGFloat price) {
    if ((unsigned long)(price * 100.) % 100==0) {
        return [NSString stringWithFormat:@"%ld", (unsigned long)price];
    } else {
        return [NSString stringWithFormat:@"%.2f", price];
    }
}

#define kExExExBigFont [UIFont systemFontOfSize:MIN(28,kScreenWidth*0.075)]
#define kExtraExtraBigFont [UIFont systemFontOfSize:MIN(24,kScreenWidth*0.065)]
#define kExtraBigFont [UIFont systemFontOfSize:MIN(20,kScreenWidth*0.055)]
#define kBigFont  [UIFont systemFontOfSize:MIN(18,kScreenWidth*0.05)]
#define kMediumFont [UIFont systemFontOfSize:MIN(16, kScreenWidth*0.045)]
#define kSmallFont [UIFont systemFontOfSize:MIN(14, kScreenWidth*0.04)]
#define kExtraSmallFont [UIFont systemFontOfSize:MIN(12, kScreenWidth*0.035)]
#define kExExSmallFont [UIFont systemFontOfSize:MIN(10, kScreenWidth*0.03)]

#define kBoldMediumFont [UIFont boldSystemFontOfSize:MIN(16, kScreenWidth*0.045)]
#define kBoldBigFont [UIFont boldSystemFontOfSize:MIN(18,kScreenWidth*0.05)]

#define kExtraBigVerticalSpacing (kScreenHeight * 0.016)
#define kBigVerticalSpacing (kScreenHeight * 0.012)
#define kMediumVerticalSpacing (kScreenHeight * 0.008)
#define kSmallVerticalSpacing (kScreenHeight * 0.004)

#define kExtraBigHorizontalSpacing  (kScreenWidth * 0.04)
#define kBigHorizontalSpacing       (kScreenWidth * 0.024)
#define kMediumHorizontalSpacing    (kScreenWidth * 0.016)
#define kSmallHorizontalSpacing     (kScreenWidth * 0.008)

#define kLeftRightContentMarginSpacing kExtraBigHorizontalSpacing
#define kTopBottomContentMarginSpacing kExtraBigVerticalSpacing
#endif /* YYKCommonDef_h */
