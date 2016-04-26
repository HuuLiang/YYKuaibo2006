//
//  YYKChannel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannel.h"

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
@end
