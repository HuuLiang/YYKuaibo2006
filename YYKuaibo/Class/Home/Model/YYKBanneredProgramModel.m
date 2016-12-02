//
//  YYKBanneredProgramModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBanneredProgramModel.h"

@implementation YYKBanneredProgramResponse

- (Class)columnListElementClass {
    return [YYKChannel class];
}

@end

@implementation YYKBanneredProgramModel

+ (Class)responseClass {
    return [YYKBanneredProgramResponse class];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fetchedProgramList = [YYKChannel allPersistedObjectsInSpace:kHomePersistenceSpace withDecryptBlock:^NSString *(NSString *propertyName, id instance) {
            return [YYKChannel cryptPasswordForProperty:propertyName withInstance:instance];
        }];
        
        [self filterProgramTypes];
    }
    return self;
}

- (BOOL)fetchProgramsInSpace:(YYKBanneredProgramSpace)space withCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:space == YYKBanneredProgramSpaceHome ? YYK_HOME_VIDEO_URL : YYK_VIP_VIDEO_URL
                         standbyURLPath:[YYKUtil getStandByUrlPathWithOriginalUrl:space == YYKBanneredProgramSpaceHome ? YYK_HOME_VIDEO_URL : YYK_VIP_VIDEO_URL params:nil]
                             withParams:nil
                        responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        @strongify(self);
                        
                        if (!self) {
                            return ;
                        }
                        
                        NSArray *programs;
                        if (respStatus == QBURLResponseSuccess) {
                            YYKBanneredProgramResponse *resp = (YYKBanneredProgramResponse *)self.response;
                            programs = resp.columnList;
                            self->_fetchedProgramList = programs;
                            
                            [self filterProgramTypes];
                            
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                if (![YYKChannel persist:self->_fetchedProgramList inSpace:kHomePersistenceSpace withPrimaryKey:kChannelPrimaryKey clearBeforePersistence:YES encryptBlock:^NSString *(NSString *propertyName, id instance) {
                                    return [YYKChannel cryptPasswordForProperty:propertyName withInstance:instance];
                                }]) {
                                    DLog(@"Fail to persist in %@", NSStringFromClass([self class]));
                                }
                            });
                        }
                        
                        if (handler) {
                            handler(respStatus==QBURLResponseSuccess, programs);
                        }
                    }];
    return success;
}

- (void)filterProgramTypes {
    _fetchedVideoProgramList = [self.fetchedProgramList bk_select:^BOOL(id obj)
                                {
                                    YYKProgramType type = ((YYKChannel *)obj).type.unsignedIntegerValue;
                                    return type == YYKProgramTypeVideo;
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
    
    NSArray<YYKChannel *> *rankingChannels = [self.fetchedProgramList bk_select:^BOOL(id obj) {
        YYKProgramType type = ((YYKChannel *)obj).type.unsignedIntegerValue;
        return type == YYKProgramTypeRanking;
    }];
    _fetchedRankingChannel = rankingChannels.firstObject;
}
@end
