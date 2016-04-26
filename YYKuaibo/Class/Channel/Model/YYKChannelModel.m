//
//  YYKChannelModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelModel.h"

@implementation YYKChannelResponse

- (Class)columnListElementClass {
    return [YYKChannel class];
}

@end

@implementation YYKChannelModel

+ (Class)responseClass {
    return [YYKChannelResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        YYKChannelResponse *resp = self.response;
        _fetchedChannels = resp.columnList;
    }
    return self;
}

- (BOOL)fetchChannelsWithCompletionHandler:(YYKFetchChannelsCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:YYK_CHANNEL_URL
                         standbyURLPath:YYK_STANDBY_CHANNEL_URL
                             withParams:nil
                        responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        @strongify(self);
                        if (respStatus == YYKURLResponseSuccess) {
                            YYKChannelResponse *channelResp = (YYKChannelResponse *)self.response;
                            self->_fetchedChannels = channelResp.columnList;
                            
                            if (handler) {
                                handler(YES, self->_fetchedChannels);
                            }
                        } else {
                            if (handler) {
                                handler(NO, nil);
                            }
                        }
                    }];
    return success;
}

@end
