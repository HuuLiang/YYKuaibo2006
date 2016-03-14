//
//  YYKVideo.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKVideo.h"

static NSString *const kVideoHistoryKeyName = @"yykuaibov_video_history_keyname";

@implementation YYKVideo

+ (NSArray<YYKVideo *> *)allPlayedVideos {
    NSMutableArray *playedVideos = [NSMutableArray array];
    NSArray<NSDictionary *> *history = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoHistoryKeyName];
    [history enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YYKVideo *video = [YYKVideo videoFromPersistentEntry:obj];
        [playedVideos addObject:video];
    }];
    return playedVideos.count > 0 ? playedVideos : nil;
}

- (NSDictionary *)persistentEntry {
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry safelySetObject:self.programId forKey:@"programId"];
    [entry safelySetObject:self.title forKey:@"title"];
    [entry safelySetObject:self.specialDesc forKey:@"specialDesc"];
    [entry safelySetObject:self.videoUrl forKey:@"videoUrl"];
    [entry safelySetObject:self.coverImg forKey:@"coverImg"];
    [entry safelySetObject:self.spec forKey:@"spec"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDefaultDateFormat];
    NSString *dateString = [formatter stringFromDate:self.playedDate];
    [entry safelySetObject:dateString forKey:@"playedDate"];
    return entry;
}

+ (instancetype)videoFromPersistentEntry:(NSDictionary *)entry {
    YYKVideo *video = [[self alloc] init];
    video.programId = entry[@"programId"];
    video.title = entry[@"title"];
    video.specialDesc = entry[@"specialDesc"];
    video.videoUrl = entry[@"videoUrl"];
    video.coverImg = entry[@"coverImg"];
    video.spec = entry[@"spec"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDefaultDateFormat];
    video.playedDate = [formatter dateFromString:entry[@"playedDate"]];
    return video;
}

- (void)didPlay {
    self.playedDate = [NSDate date];
    
    NSArray *history = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoHistoryKeyName];
    NSMutableArray *historyM = [history mutableCopy];
    if (!historyM) {
        historyM = [NSMutableArray array];
    }
    
    NSDictionary *existingVideo = [historyM bk_match:^BOOL(NSDictionary *obj) {
        if ([self.programId isEqualToNumber:obj[@"programId"]]) {
            return YES;
        }
        return NO;
    }];
    
    if (existingVideo) {
        [historyM removeObject:existingVideo];
    }
    [historyM addObject:self.persistentEntry];
    
    [[NSUserDefaults standardUserDefaults] setObject:historyM forKey:kVideoHistoryKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)playedDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:self.playedDate];
    return dateString;
}

@end