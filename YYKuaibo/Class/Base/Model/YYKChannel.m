//
//  YYKChannel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannel.h"
#import "YYKProgram.h"

@implementation YYKChannel

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[YYKChannel class]]) {
        return NO;
    }
    
    return [self.columnId isEqualToNumber:[object columnId]];
}

- (NSUInteger)hash {
    return self.columnId.hash;
}

- (Class)programListElementClass {
    return [YYKProgram class];
}

+ (NSString *)cryptPasswordForProperty:(NSString *)propertyName withInstance:(id)instance {
    if ([instance class] == [YYKChannel class]) {
        NSArray *cryptProperties = @[@"columnDesc",@"name",@"columnImg",@"spreadUrl"];
        if ([cryptProperties containsObject:propertyName]) {
            return kPersistenceCryptPassword;
        }
    } else if ([instance class] == [YYKProgram class]) {
        NSArray *cryptProperties = @[@"videoUrl",@"coverImg",@"offUrl",@"title",@"specialDesc"];
        if ([cryptProperties containsObject:propertyName]) {
            return kPersistenceCryptPassword;
        }
    }
    return nil;
}
//+ (BOOL)persistChannels:(NSArray<YYKChannel *> *)channels inSpace:(NSString *)spaceName withPrimaryKey:(NSString *)primaryKey clearBeforePersistence:(BOOL)shouldClear {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = paths.firstObject;
//    if (!path) {
//        return NO;
//    }
//    
//    NSString *file = [NSString stringWithFormat:@"%@/%@", path, spaceName];
//    NSMutableArray *arr = shouldClear ? [NSMutableArray array] : [NSArray arrayWithContentsOfFile:file].mutableCopy;
//    // Remove all elements that have the same primary key value.
//    NSArray *updateObjects = [arr bk_select:^BOOL(id obj) {
//        id primaryValue = [arr valueForKey:primaryKey];
//        return [channels bk_any:^BOOL(id obj) {
//            return [[obj valueForKey:primaryKey] isEqual:primaryValue];
//        }];
//    }];
//    [arr removeObjectsInArray:updateObjects];
//    
//    [channels enumerateObjectsUsingBlock:^(YYKChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSDictionary *dicRep = obj.dictionaryRepresentation;
//        if (dicRep) {
//            [arr addObject:dicRep];
//        }
//    }];
//    
//    if (arr.count == 0) {
//        return NO;
//    }
//    
//    return [arr writeToFile:file atomically:YES];
//}
//
//+ (NSArray<YYKChannel *> *)allPersistedChannelsInSpace:(NSString *)spaceName {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = paths.firstObject;
//    if (!path) {
//        return nil;
//    }
//    
//    NSString *file = [NSString stringWithFormat:@"%@/%@", path, spaceName];
//    NSArray *arr = [NSArray arrayWithContentsOfFile:file];
//    NSMutableArray *retArr = [NSMutableArray array];
//    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        YYKChannel *channel = [self objectFromDictionary:obj];
//        if (channel) {
//            [retArr addObject:channel];
//        }
//    }];
//    return retArr.count > 0 ? retArr : nil;
//}
@end
