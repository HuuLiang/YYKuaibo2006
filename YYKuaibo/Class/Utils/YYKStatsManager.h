//
//  YYKStatsManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YYKStatsPayAction) {
    YYKStatsPayActionUnknown,
    YYKStatsPayActionClose,
    YYKStatsPayActionGoToPay,
    YYKStatsPayActionPayBack
};

@class YYKStatsInfo;
@class YYKChannel;
@interface YYKStatsManager : NSObject

+ (instancetype)sharedManager;

- (void)addStats:(YYKStatsInfo *)statsInfo;
- (void)removeStats:(NSArray<YYKStatsInfo *> *)statsInfos;
- (void)scheduleStatsUploadWithTimeInterval:(NSTimeInterval)timeInterval;

// Helper Methods
- (void)statsCPCWithChannel:(YYKChannel *)channel inTabIndex:(NSUInteger)tabIndex;
- (void)statsCPCWithProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex
            isProgramDetail:(BOOL)isProgramDetail;

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forClickCount:(NSUInteger)clickCount;
- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forSlideCount:(NSUInteger)slideCount;
- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forBanner:(NSNumber *)bannerColumnId withSlideCount:(NSUInteger)slideCount;
- (void)statsStopDurationAtTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex;

- (void)statsPayWithOrderNo:(NSString *)orderNo
                  payAction:(YYKStatsPayAction)payAction
                  payResult:(QBPayResult)payResult
                 forProgram:(YYKProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(YYKChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex;

- (void)statsPayWithPaymentInfo:(YYKPaymentInfo *)paymentInfo
                   forPayAction:(YYKStatsPayAction)payAction
                    andTabIndex:(NSUInteger)tabIndex
                    subTabIndex:(NSUInteger)subTabIndex;

@end
