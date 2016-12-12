//
//  YYKChannelModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelModel.h"

@interface YYKChannelResponse : YYKURLResponse
@property (nonatomic,retain) NSMutableArray<YYKChannel *> *columnList;

@end

@implementation YYKChannelResponse

- (Class)columnListElementClass {
    return [YYKChannel class];
}

@end

@implementation YYKChannelModel
RequestTimeOutInterval

+ (Class)responseClass {
    return [YYKChannelResponse class];
}

- (BOOL)fetchChannelsInSpace:(YYKChannelSpace)space withCompletionHandler:(YYKCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:space == YYKChannelSpaceSVIP ? YYK_VIP_CHANNEL_URL : YYK_CHANNEL_URL
                     standbyURLPath:[YYKUtil getStandByUrlPathWithOriginalUrl:space == YYKChannelSpaceSVIP ? YYK_VIP_CHANNEL_URL : YYK_CHANNEL_URL params:nil]
                         withParams:nil
                    responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage) {
                        @strongify(self);
                        if (!self) {
                            return ;
                        }
                        
                        NSArray *channels;
                        if (respStatus == QBURLResponseSuccess) {
                            YYKChannelResponse *resp = self.response;
                            channels = resp.columnList;
                            self->_fetchedChannels = channels;
                        }
                        
                        SafelyCallBlock(handler, respStatus == QBURLResponseSuccess, channels);

                    }];
    

    return ret;
}
@end
