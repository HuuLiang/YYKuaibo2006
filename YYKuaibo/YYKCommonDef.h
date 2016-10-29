//
//  YYKCommonDef.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#ifndef YYKCommonDef_h
#define YYKCommonDef_h

#import <QBDefines.h>
#import <QBPaymentDefines.h>
#import <QBURLRequest.h>
#import <QBURLResponse.h>
#import <QBEncryptedURLRequest.h>

#define YYK_IMAGE_TOKEN_ENABLED

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

#define DLog QBLog

#define DefineLazyPropertyInitialization(propertyType, propertyName) QBDefineLazyPropertyInitialization(propertyType, propertyName)
#define SafelyCallBlock(block,...) QBSafelyCallBlock(block, __VA_ARGS__)
#define SafelyCallBlockAndRelease(block,...) QBSafelyCallBlockAndRelease(block, __VA_ARGS__)

#define SynthesizePropertyClassMethod(propName, propClass) \
- (Class)propName##Class { return [propClass class]; }

#define SynthesizeContainerPropertyElementClassMethod(propName, elementClass) \
- (Class)propName##ElementClass { return [elementClass class]; }

#define kPaidNotificationName @"yykuaibo_paid_notification"
#define kDefaultDateFormat    @"yyyyMMddHHmmss"
#define kDefaultCollectionViewInteritemSpace  (5)

#define kBarColor [UIColor colorWithHexString:@"#172857"]
#define kThemeColor [UIColor colorWithHexString:@"#ab47bc"]
#define kDefaultTextColor [UIColor colorWithHexString:@"#8eb1e5"]
#define kDefaultLightTextColor [UIColor colorWithHexString:@"#5f7699"]
#define kDarkBackgroundColor [UIColor colorWithHexString:@"#011122"]
#define kLightBackgroundColor [UIColor colorWithHexString:@"#0e2341"]
#define kDefaultSectionBackgroundColor kLightBackgroundColor

#define QBPayPointTypeVIP (1)
#define QBPayPointTypeSVIP (2)

static NSString *const kChannelPersistenceSpace = @"yykuaibo_1";
static NSString *const kChannelProgramPersistenceSpace = @"yykuaibo_2";
static NSString *const kHomePersistenceSpace = @"yykuaibo_3";
static NSString *const kVIPPersistenceSpace = @"yykuaibo_4";

static NSString *const kPersistenceCryptPassword = @"#%Q%$#afaf3134134";
static NSString *const kChannelPrimaryKey = @"columnId";
static NSString *const kSVIPText = @"黑钻VIP";
static NSString *const kSVIPShortText = @"黑钻";


typedef QBAction YYKAction;
typedef QBCompletionHandler YYKCompletionHandler;
typedef QBPaymentCompletionHandler YYKPaymentCompletionHandler;
typedef QBPaymentInfo YYKPaymentInfo;
typedef QBURLRequest YYKURLRequest;
typedef QBURLResponse YYKURLResponse;
typedef QBEncryptedURLRequest YYKEncryptedURLRequest;

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

#define kWidth(width)                  kScreenWidth  * width  / 750

#define kLeftRightContentMarginSpacing kExtraBigHorizontalSpacing
#define kTopBottomContentMarginSpacing kExtraBigVerticalSpacing
#endif /* YYKCommonDef_h */
