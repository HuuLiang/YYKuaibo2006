//
//  YYKChannelProgramModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelProgramModel.h"

@implementation YYKChannelProgramModel
RequestTimeOutInterval

+ (Class)responseClass {
    return [YYKChannel class];
}

- (BOOL)fetchVideosInColumn:(NSNumber *)columnId page:(NSUInteger)page withCompletionHandler:(YYKCompletionHandler)completionHandler {
    if (columnId == nil) {
        SafelyCallBlock(completionHandler, NO, nil);
        return NO;
    }
    
    @weakify(self);
    NSDictionary *params = @{@"columnId":columnId, @"page":@(page)};
    
   BOOL ret = [self requestURLPath:YYK_CHANNEL_PROGRAM_URL
                    standbyURLPath:[YYKUtil getStandByUrlPathWithOriginalUrl:YYK_CHANNEL_PROGRAM_URL params:params]
                    withParams:params
                   responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage) {
       @strongify(self);
       if (!self) {
           return ;
       }
       
       YYKChannel *channel;
       if (respStatus == QBURLResponseSuccess) {
           channel = self.response;
           self->_fetchedVideoChannel = channel;
       }
       
       SafelyCallBlock(completionHandler, respStatus==QBURLResponseSuccess, channel);

   }];
    
       return ret;
}
@end
