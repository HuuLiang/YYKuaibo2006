//
//  YYKChannelProgramModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelProgramModel.h"

@implementation YYKChannelProgramModel

+ (Class)responseClass {
    return [YYKChannel class];
}

- (NSArray<YYKChannel *> *)cachedChannels {
    return [YYKChannel allPersistedObjectsInSpace:kChannelProgramPersistenceSpace withDecryptBlock:^NSString *(NSString *propertyName, id instance) {
        return [YYKChannel cryptPasswordForProperty:propertyName withInstance:instance];
    }];
}

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(YYKFetchChannelProgramCompletionHandler)handler {
    if (columnId == nil) {
        if (handler) {
            handler(NO, nil);
        }
        return NO;
    }
    
    @weakify(self);
    NSDictionary *params = @{@"columnId":columnId, @"page":@(pageNo), @"pageSize":@(pageSize)};
    NSString *standbyURLPath = [NSString stringWithFormat:YYK_STANDBY_CHANNEL_PROGRAM_URL, columnId, @(pageNo)];
    BOOL success = [self requestURLPath:YYK_CHANNEL_PROGRAM_URL
                         standbyURLPath:standbyURLPath
                             withParams:params
                        responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        @strongify(self);
                        
                        YYKChannel *channel;
                        if (respStatus == YYKURLResponseSuccess) {
                            channel = (YYKChannel *)self.response;
                            self.fetchedChannel = channel;
                            
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                if (![YYKChannel persist:@[channel]
                                                 inSpace:kChannelProgramPersistenceSpace
                                          withPrimaryKey:kChannelPrimaryKey
                                  clearBeforePersistence:NO encryptBlock:^NSString *(NSString *propertyName, id instance) {
                                      return [YYKChannel cryptPasswordForProperty:propertyName withInstance:instance];
                                  }]) {
                                      DLog(@"Persist Channel Program fails");
                                }
                            });
                        }
                        SafelyCallBlock(handler,respStatus==YYKURLResponseSuccess,channel);
                    }];
    return success;
}

@end