//
//  YYKStatsManager.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKStatsManager.h"
#import "YYKCPCStatsModel.h"
#import "YYKTabStatsModel.h"
#import "YYKPayStatsModel.h"
#import "YYKPaymentInfo.h"
#import "MobClick.h"

static NSString *const kUmengCPCChannelEvent = @"CPC_CHANNEL";
static NSString *const kUmengCPCProgramEvent = @"CPC_PROGRAM";
static NSString *const kUmengTabEvent = @"TAB_STATS";
static NSString *const kUmengPayEvent = @"PAY_STATS";

@interface YYKStatsManager ()
@property (nonatomic,retain) dispatch_queue_t queue;
@property (nonatomic,retain,readonly) YYKCPCStatsModel *cpcStats;
@property (nonatomic,retain,readonly) YYKTabStatsModel *tabStats;
@property (nonatomic,retain,readonly) YYKPayStatsModel *payStats;
@property (nonatomic,retain,readonly) NSDate *statsDate;
@end

@implementation YYKStatsManager
@synthesize cpcStats = _cpcStats;
@synthesize tabStats = _tabStats;
@synthesize payStats = _payStats;

DefineLazyPropertyInitialization(YYKCPCStatsModel, cpcStats)
DefineLazyPropertyInitialization(YYKTabStatsModel, tabStats)
DefineLazyPropertyInitialization(YYKPayStatsModel, payStats)

- (dispatch_queue_t)queue {
    if (_queue) {
        return _queue;
    }
    
    _queue = dispatch_queue_create("com.yykuaibo.app.statsq", nil);
    return _queue;
}

+ (instancetype)sharedManager {
    static YYKStatsManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _statsDate = [NSDate date];
    }
    return self;
}

- (void)addStats:(YYKStatsInfo *)statsInfo {
    dispatch_async(self.queue, ^{
        [statsInfo save];
    });
}

- (void)removeStats:(NSArray<YYKStatsInfo *> *)statsInfos {
    dispatch_async(self.queue, ^{
        [YYKStatsInfo removeStatsInfos:statsInfos];
    });
}

- (void)scheduleStatsUploadWithTimeInterval:(NSTimeInterval)timeInterval {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (1) {
            dispatch_async(self.queue, ^{
                [self uploadStatsInfos:[YYKStatsInfo allStatsInfos]];
            });
            sleep(timeInterval);
        }
    });
}

- (void)uploadStatsInfos:(NSArray<YYKStatsInfo *> *)statsInfos {
    if (statsInfos.count == 0) {
        return ;
    }
    
    NSArray<YYKStatsInfo *> *cpcStats = [statsInfos bk_select:^BOOL(YYKStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == YYKStatsTypeColumnCPC
        || statsInfo.statsType.unsignedIntegerValue == YYKStatsTypeProgramCPC;
    }];
    
    NSArray<YYKStatsInfo *> *tabStats = [statsInfos bk_select:^BOOL(YYKStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == YYKStatsTypeTabCPC
        || statsInfo.statsType.unsignedIntegerValue == YYKStatsTypeTabPanning
        || statsInfo.statsType.unsignedIntegerValue == YYKStatsTypeTabStay
        || statsInfo.statsType.unsignedIntegerValue == YYKStatsTypeBannerPanning;
    }];
    
    NSArray<YYKStatsInfo *> *payStats = [statsInfos bk_select:^BOOL(YYKStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == YYKStatsTypePay;
    }];
    
    if (cpcStats.count > 0) {
        DLog(@"Commit CPC stats...");
        [self.cpcStats statsCPCWithStatsInfos:cpcStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [YYKStatsInfo removeStatsInfos:cpcStats];
                DLog(@"Commit CPC stats successfully!");
            } else {
                DLog(@"Commit CPC stats with failure!");
            }
        }];
    }
    
    if (tabStats.count > 0) {
        DLog(@"Commit TAB stats...");
        [self.tabStats statsTabWithStatsInfos:tabStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [YYKStatsInfo removeStatsInfos:tabStats];
                DLog(@"Commit TAB stats successfully");
            } else {
                DLog(@"Commint TAB stats with failure!");
            }
        }];
    }
    
    if (payStats.count > 0) {
        DLog(@"Commit PAY stats...");
        [self.payStats statsPayWithStatsInfos:payStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [YYKStatsInfo removeStatsInfos:payStats];
                DLog(@"Commit PAY stats successfully!");
            } else {
                DLog(@"Commit PAY stats with failure!");
            }
        }];
    }
}

- (void)statsCPCWithChannel:(YYKChannel *)channel inTabIndex:(NSUInteger)tabIndex {
    YYKStatsInfo *statsInfo = [[YYKStatsInfo alloc] init];
    statsInfo.tabpageId = @(tabIndex);
    statsInfo.columnId = channel.realColumnId;
    statsInfo.columnType = channel.type;
    statsInfo.statsType = @(YYKStatsTypeColumnCPC);
    [self addStats:statsInfo];
    
    [MobClick event:kUmengCPCChannelEvent attributes:[statsInfo umengAttributes]];
}

- (void)statsCPCWithProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex
{
    YYKStatsInfo *statsInfo = [[YYKStatsInfo alloc] init];
    if (channel) {
        statsInfo.columnId = channel.realColumnId;
        statsInfo.columnType = channel.type;
    }
    statsInfo.tabpageId = @(tabIndex);
    if (subTabIndex != NSNotFound) {
        statsInfo.subTabpageId = @(subTabIndex);
    }
    
    statsInfo.programId = program.programId;
    statsInfo.programType = program.type;
    statsInfo.programLocation = @(programLocation);
    statsInfo.statsType = @(YYKStatsTypeProgramCPC);
    [self addStats:statsInfo];
    
    [MobClick event:kUmengCPCProgramEvent attributes:statsInfo.umengAttributes];
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forClickCount:(NSUInteger)clickCount {
    dispatch_async(self.queue, ^{
        NSArray<YYKStatsInfo *> *statsInfos = [YYKStatsInfo statsInfosWithStatsType:YYKStatsTypeTabCPC tabIndex:tabIndex subTabIndex:subTabIndex];
        YYKStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[YYKStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex);
            }
            statsInfo.statsType = @(YYKStatsTypeTabCPC);
        }
        
        statsInfo.clickCount = @(statsInfo.clickCount.unsignedIntegerValue + clickCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forSlideCount:(NSUInteger)slideCount {
    dispatch_async(self.queue, ^{
        NSArray<YYKStatsInfo *> *statsInfos = [YYKStatsInfo statsInfosWithStatsType:YYKStatsTypeTabPanning tabIndex:tabIndex subTabIndex:subTabIndex];
        YYKStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[YYKStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex);
            }
            statsInfo.statsType = @(YYKStatsTypeTabPanning);
        }
        
        statsInfo.slideCount = @(statsInfo.slideCount.unsignedIntegerValue + slideCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsStopDurationAtTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex {
    dispatch_async(self.queue, ^{
        NSArray<YYKStatsInfo *> *statsInfos = [YYKStatsInfo statsInfosWithStatsType:YYKStatsTypeTabStay tabIndex:tabIndex subTabIndex:subTabIndex];
        YYKStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[YYKStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex);
            }
            statsInfo.statsType = @(YYKStatsTypeTabStay);
        }
        
        NSUInteger durationSinceStats = [[NSDate date] timeIntervalSinceDate:self.statsDate];
        statsInfo.stopDuration = @(statsInfo.stopDuration.unsignedIntegerValue + durationSinceStats);
        [statsInfo save];
        
        [self resetStatsDate];
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forBanner:(NSNumber *)bannerColumnId withSlideCount:(NSUInteger)slideCount {
    dispatch_async(self.queue, ^{
        NSArray<YYKStatsInfo *> *statsInfos = [YYKStatsInfo statsInfosWithStatsType:YYKStatsTypeBannerPanning tabIndex:tabIndex subTabIndex:subTabIndex];
        YYKStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[YYKStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex);
            statsInfo.statsType = @(YYKStatsTypeBannerPanning);
            statsInfo.columnId = bannerColumnId;
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex);
            }
        }
        
        statsInfo.slideCount = @(statsInfo.slideCount.unsignedIntegerValue + slideCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)resetStatsDate {
    _statsDate = [NSDate date];
}

- (void)statsPayWithOrderNo:(NSString *)orderNo
                  payAction:(YYKStatsPayAction)payAction
                  payResult:(PAYRESULT)payResult
                 forProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex
{
    dispatch_async(self.queue, ^{
        YYKStatsInfo *statsInfo = [[YYKStatsInfo alloc] init];
        statsInfo.tabpageId = @(tabIndex);
        if (subTabIndex != NSNotFound) {
            statsInfo.subTabpageId = @(subTabIndex);
        }
        statsInfo.columnId = channel.columnId;
        statsInfo.columnType = channel.type;
        statsInfo.programId = program.programId;
        statsInfo.programType = program.type;
        statsInfo.programLocation = @(programLocation);
        statsInfo.isPayPopup = @(1);
        if (payAction == YYKStatsPayActionClose) {
            statsInfo.isPayPopupClose = @(1);
        } else if (payAction == YYKStatsPayActionGoToPay) {
            statsInfo.isPayConfirm = @(1);
        } else if (payAction == YYKStatsPayActionPayBack) {
            NSDictionary *payStautsMapping = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(2), @(PAYRESULT_ABANDON):@(3)};
            NSNumber *payStatus = payStautsMapping[@(payResult)];
            statsInfo.payStatus = payStatus;
        } else {
            return ;
        }
        
        statsInfo.paySeq = @([YYKUtil launchSeq]);
        statsInfo.statsType = @(YYKStatsTypePay);
        statsInfo.network = @([YYKNetworkInfo sharedInfo].networkStatus);
        [statsInfo save];
        
        [MobClick event:kUmengPayEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsPayWithPaymentInfo:(YYKPaymentInfo *)paymentInfo
                   forPayAction:(YYKStatsPayAction)payAction
                    andTabIndex:(NSUInteger)tabIndex
                    subTabIndex:(NSUInteger)subTabIndex
{
    dispatch_async(self.queue, ^{
        YYKStatsInfo *statsInfo = [[YYKStatsInfo alloc] init];
        statsInfo.tabpageId = @(tabIndex);
        if (subTabIndex != NSNotFound) {
            statsInfo.subTabpageId = @(subTabIndex);
        }
        statsInfo.columnId = paymentInfo.columnId;
        statsInfo.columnType = paymentInfo.columnType;
        statsInfo.programId = paymentInfo.contentId;
        statsInfo.programType = paymentInfo.contentType;
        statsInfo.programLocation = paymentInfo.contentLocation;
        statsInfo.isPayPopup = @(1);
        if (payAction == YYKStatsPayActionClose) {
            statsInfo.isPayPopupClose = @(1);
        } else if (payAction == YYKStatsPayActionGoToPay) {
            statsInfo.isPayConfirm = @(1);
        } else if (payAction == YYKStatsPayActionPayBack) {
            NSDictionary *payStautsMapping = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(2), @(PAYRESULT_ABANDON):@(3)};
            NSNumber *payStatus = payStautsMapping[paymentInfo.paymentResult];
            statsInfo.payStatus = payStatus;
        } else {
            return ;
        }
    
        statsInfo.paySeq = @([YYKUtil launchSeq]);
        statsInfo.statsType = @(YYKStatsTypePay);
        statsInfo.network = @([YYKNetworkInfo sharedInfo].networkStatus);
        [statsInfo save];
        
        [MobClick event:kUmengPayEvent attributes:statsInfo.umengAttributes];
    });
}

@end
