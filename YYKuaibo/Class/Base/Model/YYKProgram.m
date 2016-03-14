//
//  YYKProgram.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKProgram.h"

@implementation YYKProgramUrl

@end

@implementation YYKProgram

- (Class)urlListElementClass {
    return [YYKProgramUrl class];
}

@end

@implementation YYKPrograms

- (Class)programListElementClass {
    return [YYKProgram class];
}

@end
