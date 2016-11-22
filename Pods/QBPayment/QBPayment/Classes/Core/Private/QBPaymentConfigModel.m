//
//  QBPaymentConfigModel.m
//  QBuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "QBPaymentConfigModel.h"
#import "QBPaymentConfig.h"
#import "RACEXTScope.h"
#import "QBNetworkingConfiguration.h"

static NSString *const kPaymentConfigURL = @"http://pay.zcqcmj.com/paycenter/appPayConfig.json";
static NSString *const kTestPaymentConfigURL = @"http://120.24.252.114:8084/paycenter/appPayConfig.json";

@implementation QBPaymentConfigModel

+ (Class)responseClass {
    return [QBPaymentConfig class];
}

- (BOOL)fetchConfigWithCompletionHandler:(QBCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:self.isTest ? kTestPaymentConfigURL : kPaymentConfigURL
                     standbyURLPath:nil
                         withParams:@{@"appId":self.configuration.RESTAppId,
                                      @"channelNo":self.configuration.channelNo,
                                      @"pv":self.configuration.RESTpV}
                    responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        QBPaymentConfig *config;
        if (respStatus == QBURLResponseSuccess) {
            self->_loaded = YES;
            
            config = self.response;
            [config setAsCurrentConfig];
            
            QBLog(@"Payment config loaded!");
        }
        
        if (handler) {
            handler(respStatus == QBURLResponseSuccess, config);
        }
    }];
    return ret;
}
@end
