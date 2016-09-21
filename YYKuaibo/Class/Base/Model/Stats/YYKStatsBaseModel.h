//
//  YYKStatsBaseModel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

typedef NS_ENUM(NSUInteger, YYKStatsType) {
    YYKStatsTypeUnknown,
    YYKStatsTypeColumnCPC,
    YYKStatsTypeProgramCPC,
    YYKStatsTypeTabCPC,
    YYKStatsTypeTabPanning,
    YYKStatsTypeTabStay,
    YYKStatsTypeBannerPanning,
    YYKStatsTypePay = 1000
};

typedef NS_ENUM(NSInteger, YYKStatsNetwork) {
    YYKStatsNetworkUnknown = 0,
    YYKStatsNetworkWifi = 1,
    YYKStatsNetwork2G = 2,
    YYKStatsNetwork3G = 3,
    YYKStatsNetwork4G = 4,
    YYKStatsNetworkOther = -1
};

typedef NS_ENUM(NSUInteger, YYKStatsCPCAction) {
    YYKStatsCPCActionUnknown,
    YYKStatsCPCActionProgramDetail,
    YYKStatsCPCActionProgramPlaying
};

@interface YYKStatsInfo : DBPersistence

// Unique ID
@property (nonatomic) NSNumber *statsId;

// System Info
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *pv;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *osv;

// Tab/Column/Program
@property (nonatomic) NSNumber *tabpageId;
@property (nonatomic) NSNumber *subTabpageId;
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *columnType;
@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSNumber *programType;
@property (nonatomic) NSNumber *programLocation;
@property (nonatomic) NSNumber *action;
@property (nonatomic) NSNumber *statsType; //YYKStatsType

// Accumalation stats
@property (nonatomic) NSNumber *clickCount;
@property (nonatomic) NSNumber *slideCount;
@property (nonatomic) NSNumber *stopDuration;

// Payment
@property (nonatomic) NSNumber *isPayPopup;
@property (nonatomic) NSNumber *isPayPopupClose;
@property (nonatomic) NSNumber *isPayConfirm;
@property (nonatomic) NSNumber *payStatus;
@property (nonatomic) NSNumber *paySeq;
@property (nonatomic) NSString *orderNo;
@property (nonatomic) NSNumber *network; //YYKStatsNetwork
//
+ (NSArray<YYKStatsInfo *> *)allStatsInfos;
+ (NSArray<YYKStatsInfo *> *)statsInfosWithStatsType:(YYKStatsType)statsType;
+ (NSArray<YYKStatsInfo *> *)statsInfosWithStatsType:(YYKStatsType)statsType tabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex;
+ (void)removeStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos;

- (BOOL)save;
- (BOOL)removeFromDB;
- (NSDictionary *)RESTData;
- (NSDictionary *)umengAttributes;

@end

@interface YYKStatsResponse : YYKURLResponse
@property (nonatomic) NSNumber *errCode;
@end

@interface YYKStatsBaseModel : YYKEncryptedURLRequest

- (NSArray<NSDictionary *> *)validateParamsWithStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos;
- (NSArray<NSDictionary *> *)validateParamsWithStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos shouldIncludeStatsType:(BOOL)includeStatsType;

@end
