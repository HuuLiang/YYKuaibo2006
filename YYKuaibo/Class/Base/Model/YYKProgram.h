//
//  YYKProgram.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YYKProgramType) {
    YYKProgramTypeNone = 0,
    YYKProgramTypeVideo = 1,
    YYKProgramTypePicture = 2,
    YYKProgramTypeSpread = 3,
    YYKProgramTypeBanner = 4,
    YYKProgramTypeTrial = 5,
    YYKProgramTypeRanking = 6
};

@interface YYKProgramUrl : NSObject
@property (nonatomic) NSNumber *programUrlId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *url;
@property (nonatomic) NSNumber *width;
@property (nonatomic) NSNumber *height;
@end

@interface YYKProgram : NSObject

@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *specialDesc;
@property (nonatomic) NSString *videoUrl;
@property (nonatomic) NSString *coverImg;
@property (nonatomic) NSString *detailsCoverImg;
//@property (nonatomic) NSNumber *spec;
@property (nonatomic) NSNumber *payPointType; // 1、会员注册 2、付费
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic) NSString *offUrl;
@property (nonatomic) NSString *tag;
@property (nonatomic) NSString *spare;
@property (nonatomic) NSString *spareUrl;
@property (nonatomic,retain) NSArray<YYKProgramUrl *> *urlList; // type==2有集合，目前为图集url集合

// Channel info
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *realColumnId;

@property (nonatomic) NSDate *playedDate; // for history

+ (NSArray<YYKProgram *> *)allPlayedPrograms;
- (void)didPlay;

- (NSString *)playedDateString;
- (NSDictionary *)dictionaryRepresentation;

@end

//@interface YYKPrograms : YYKURLResponse
//
//@property (nonatomic) NSNumber *items;
//@property (nonatomic) NSNumber *page;
//@property (nonatomic) NSNumber *pageSize;
//
//@property (nonatomic) NSNumber *columnId;
//@property (nonatomic) NSString *name;
//@property (nonatomic) NSString *columnImg;
//@property (nonatomic) NSString *columnDesc;
//@property (nonatomic) NSNumber *type; // 1、视频 2、图片
//@property (nonatomic) NSNumber *showNumber;
//@property (nonatomic,retain) NSArray<YYKProgram *> *programList;
//@end

