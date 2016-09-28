//
//  YYKChannel.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKChannel : YYKURLResponse

@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *realColumnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnDesc;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSString *spreadUrl;
@property (nonatomic) NSNumber *type;
@property (nonatomic) NSNumber *showMode; //YYKCategoryShowMode
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;
@property (nonatomic) NSString *spare;
@property (nonatomic,retain) NSArray<YYKProgram *> *programList;

//+ (BOOL)persistChannels:(NSArray<YYKChannel *> *)channels inSpace:(NSString *)spaceName withPrimaryKey:(NSString *)primaryKey clearBeforePersistence:(BOOL)shouldClear;
//+ (NSArray<YYKChannel *> *)allPersistedChannelsInSpace:(NSString *)spaceName;
+ (NSString *)cryptPasswordForProperty:(NSString *)propertyName withInstance:(id)instance;

@end
