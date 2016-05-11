//
//  YYKChannel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYKURLResponse.h"

@interface YYKChannel : YYKURLResponse

@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *realColumnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnDesc;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSString *spreadUrl;
@property (nonatomic) NSNumber *type;
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;
@property (nonatomic,retain) NSArray<YYKProgram *> *programList;

@end
