//
//  YYKHomeVideoModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeProgramModel.h"

@implementation YYKHomeProgramResponse

- (Class)columnListElementClass {
    return [YYKChannel class];
}

@end

@implementation YYKHomeProgramModel

+ (Class)responseClass {
    return [YYKHomeProgramResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        YYKHomeProgramResponse *resp = (YYKHomeProgramResponse *)self.response;
        _fetchedProgramList = resp.columnList;
        
        [self filterProgramTypes];
    }
    return self;
}

- (BOOL)fetchProgramsWithCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:YYK_HOME_VIDEO_URL
                         standbyURLPath:YYK_STANDBY_HOME_VIDEO_URL
                             withParams:nil
                        responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        @strongify(self);
                        
                        if (!self) {
                            return ;
                        }
                        
                        NSArray *programs;
                        if (respStatus == YYKURLResponseSuccess) {
                            YYKHomeProgramResponse *resp = (YYKHomeProgramResponse *)self.response;
                            programs = resp.columnList;
                            self->_fetchedProgramList = programs;
                            
                            [self filterProgramTypes];
                        }
                        
                        if (handler) {
                            handler(respStatus==YYKURLResponseSuccess, programs);
                        }
                    }];
    return success;
}

- (void)filterProgramTypes {
    _fetchedVideoAndAdProgramList = [self.fetchedProgramList bk_select:^BOOL(id obj)
                                     {
                                         YYKProgramType type = ((YYKChannel *)obj).type.unsignedIntegerValue;
                                         return type == YYKProgramTypeVideo || type == YYKProgramTypeSpread;
                                     }];
    
    NSArray<YYKChannel *> *bannerChannels = [self.fetchedProgramList bk_select:^BOOL(id obj)
                                                {
                                                    YYKProgramType type = ((YYKChannel *)obj).type.unsignedIntegerValue;
                                                    return type == YYKProgramTypeBanner;
                                                }];
    
//    NSMutableArray *bannerPrograms = [NSMutableArray array];
//    [bannerProgramList enumerateObjectsUsingBlock:^(YYKChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.programList.count > 0) {
//            [bannerPrograms addObjectsFromArray:obj.programList];
//        }
//    }];
    _fetchedBannerChannel = bannerChannels.firstObject;
    
    NSArray<YYKChannel *> *trailChannels = [self.fetchedProgramList bk_select:^BOOL(id obj) {
        YYKProgramType type = ((YYKChannel *)obj).type.unsignedIntegerValue;
        return type == YYKProgramTypeTrial;
    }];
    
//    NSMutableArray<YYKProgram *> *trialPrograms = [NSMutableArray array];
//    [trailProgramList enumerateObjectsUsingBlock:^(YYKChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.programList.count > 0) {
//            [trialPrograms addObjectsFromArray:obj.programList];
//        }
//    }];
    _fetchedTrialChannel = trailChannels.firstObject;
}
@end