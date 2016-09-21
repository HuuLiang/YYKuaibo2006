//
//  NSMutableDictionary+SafeCoding.m
//  QBExtensions
//
//  Created by Sean Yue on 15/12/3.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "NSMutableDictionary+SafeCoding.h"

@implementation NSMutableDictionary (SafeCoding)

- (void)safelySetObject:(id)object forKey:(id <NSCopying>)key {
    if (object) {
        [self setObject:object forKey:key];
    }
}

- (void)safelySetUInt:(NSUInteger)uint forKey:(id <NSCopying>)key {
    if (uint != NSNotFound) {
        [self setObject:@(uint) forKey:key];
    }
}
@end
