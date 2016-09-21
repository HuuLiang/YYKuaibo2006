//
//  NSMutableDictionary+SafeCoding.h
//  QBExtensions
//
//  Created by Sean Yue on 15/12/3.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SafeCoding)

- (void)safelySetObject:(id)object forKey:(id <NSCopying>)key;
- (void)safelySetUInt:(NSUInteger)uint forKey:(id <NSCopying>)key;

@end
