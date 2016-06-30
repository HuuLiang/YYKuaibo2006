//
//  YYKOrderQueryModel.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/20.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKOrderQueryModel.h"

@implementation YYKOrderQueryModel

- (NSURL *)baseURL {
    return nil;
}

- (YYKURLRequestMethod)requestMethod {
    return YYKURLGetRequest;
}

- (BOOL)isPlainResponse {
    return YES;
}

+ (NSString *)signKey {
    return YYK_PAYMENT_SIGN_KEY;
}

+ (Class)responseClass {
    return [NSString class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSMutableString *paramString = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (paramString.length > 0) {
            [paramString appendString:@"&"];
        }
        
        [paramString appendFormat:@"%@=%@", key, obj];
    }];
    NSString *encryptedDataString = [paramString encryptedStringWithPassword:[YYK_PAYMENT_ENCRYPTION_PASSWORD.md5 substringToIndex:16]];
    return @{@"data":encryptedDataString};
}

- (BOOL)queryOrder:(NSString *)orderId withCompletionHandler:(YYKCompletionHandler)completionHandler {
    if (orderId == nil) {
        SafelyCallBlock(completionHandler, NO, nil);
        return NO;
    }
    
    return [self requestURLPath:YYK_ORDER_QUERY_URL
                     withParams:@{@"orderId":orderId}
                responseHandler:^(YYKURLResponseStatus respStatus, NSString *errorMessage)
    {
        SafelyCallBlock(completionHandler, respStatus == YYKURLResponseSuccess, respStatus == YYKURLResponseSuccess ? self.response : errorMessage);
    }];
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(YYKURLResponseHandler)responseHandler {
    id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    
    NSString *decryptedResponse = [self decryptResponse:jsonObj];
    self.response = decryptedResponse;
    DLog(@"Manual activation response : %@", decryptedResponse);
    SafelyCallBlock(responseHandler, decryptedResponse.length>0?YYKURLResponseSuccess:YYKURLResponseFailedByInterface, decryptedResponse.length>0?nil:@"无该订单或者该笔订单未支付");
}
@end
