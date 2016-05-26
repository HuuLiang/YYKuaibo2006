//
//  YYKProgram.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKProgram.h"

static NSString *const kVideoHistoryKeyName = @"yykuaibov_video_history_keyname";

@implementation YYKProgramUrl

@end

@implementation YYKProgram

- (Class)urlListElementClass {
    return [YYKProgramUrl class];
}

+ (NSArray<YYKProgram *> *)allPlayedPrograms {
    NSMutableArray *playedPrograms = [NSMutableArray array];
    NSArray<NSDictionary *> *history = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoHistoryKeyName];
    [history enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YYKProgram *video = [YYKProgram programFromPersistentEntry:obj];
        [playedPrograms addObject:video];
    }];
    return playedPrograms.count > 0 ? playedPrograms : nil;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry safelySetObject:self.programId forKey:@"programId"];
    [entry safelySetObject:self.title forKey:@"title"];
    [entry safelySetObject:self.specialDesc forKey:@"specialDesc"];
    [entry safelySetObject:self.videoUrl forKey:@"videoUrl"];
    [entry safelySetObject:self.coverImg forKey:@"coverImg"];
    [entry safelySetObject:self.spec forKey:@"spec"];
    [entry safelySetObject:self.type forKey:@"type"];
    [entry safelySetObject:self.payPointType forKey:@"payPointType"];
    [entry safelySetObject:self.offUrl forKey:@"offUrl"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDefaultDateFormat];
    NSString *dateString = [formatter stringFromDate:self.playedDate];
    [entry safelySetObject:dateString forKey:@"playedDate"];
    return entry;
}

+ (instancetype)programFromPersistentEntry:(NSDictionary *)entry {
    YYKProgram *program = [[self alloc] init];
    program.programId = entry[@"programId"];
    program.title = entry[@"title"];
    program.specialDesc = entry[@"specialDesc"];
    program.videoUrl = entry[@"videoUrl"];
    program.coverImg = entry[@"coverImg"];
    program.spec = entry[@"spec"];
    program.type = entry[@"type"];
    program.payPointType = entry[@"payPointType"];
    program.offUrl = entry[@"offUrl"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDefaultDateFormat];
    program.playedDate = [formatter dateFromString:entry[@"playedDate"]];
    return program;
}

- (void)didPlay {
    self.playedDate = [NSDate date];
    
    NSArray *history = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoHistoryKeyName];
    NSMutableArray *historyM = [history mutableCopy];
    if (!historyM) {
        historyM = [NSMutableArray array];
    }
    
    NSDictionary *existingProgram = [historyM bk_match:^BOOL(NSDictionary *obj) {
        if ([self.programId isEqualToNumber:obj[@"programId"]]) {
            return YES;
        }
        return NO;
    }];
    
    if (existingProgram) {
        [historyM removeObject:existingProgram];
    }
    [historyM addObject:self.dictionaryRepresentation];
    
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
//
//@implementation YYKPrograms
//
//- (Class)programListElementClass {
//    return [YYKProgram class];
//}
//
//@end
