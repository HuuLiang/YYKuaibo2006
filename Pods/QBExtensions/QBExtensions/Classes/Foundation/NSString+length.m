//
//  NSString+length.m
//  Pods
//
//  Created by Sean Yue on 15/6/2.
//
//

#import "NSString+length.h"

@implementation NSString (length)

- (BOOL)isEmpty {
    if (self == nil || self == NULL)
        return YES;
    if ([self isKindOfClass:[NSNull class]])
        return YES;
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0)
        return YES;
    if ([self isEqualToString:@"(null)"])
        return YES;
    if ([self isEqualToString:@"(null)(null)"])
        return YES;
    if ([self isEqualToString:@"<null>"])
        return YES;
    
    // return Default
    return NO;
}

@end
