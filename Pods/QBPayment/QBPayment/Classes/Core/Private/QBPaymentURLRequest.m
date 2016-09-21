//
//  QBPaymentURLRequest.m
//  Pods
//
//  Created by Sean Yue on 16/9/13.
//
//

#import "QBPaymentURLRequest.h"
#import "NSDictionary+QBSign.h"
#import "QBPaymentNetworkingConfiguration.h"
#import "QBDefines.h"

static NSString *const kQBPaymentSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kQBPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

@implementation QBPaymentURLRequest

- (QBNetworkingConfiguration *)configuration {
    return [QBPaymentNetworkingConfiguration defaultConfiguration];
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (QBURLRequestMethod)requestMethod {
    return QBURLPostRequest;
}

+ (NSString *)signKey {
    return kQBPaymentSignKey;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":self.configuration.RESTAppId,
                                   @"key":kQBPaymentSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":self.configuration.channelNo,
                                   @"pV":self.configuration.RESTpV };
    
    NSString *sign = [signParams signWithDictionary:self.commonParams keyOrders:self.keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kQBPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":self.configuration.RESTAppId};
}
@end
