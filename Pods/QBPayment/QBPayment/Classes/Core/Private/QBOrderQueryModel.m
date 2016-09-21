//
//  QBOrderQueryModel.m
//  Pods
//
//  Created by Sean Yue on 16/9/21.
//
//

#import "QBOrderQueryModel.h"
#import "NSString+md5.h"
#import "NSString+crypt.h"

static NSString *const kQueryOrderURL = @"http://phas.ihuiyx.com/pd-has/successOrderIds.json";

@implementation QBOrderQueryModel

+ (Class)responseClass {
    return [NSString class];
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSMutableString *paramString = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (paramString.length > 0) {
            [paramString appendString:@"&"];
        }
        
        [paramString appendFormat:@"%@=%@", key, obj];
    }];
    NSString *encryptedDataString = [paramString encryptedStringWithPassword:[kQBPaymentEncryptionPassword.md5 substringToIndex:16]];
    return @{@"data":encryptedDataString};
}

- (BOOL)queryOrder:(NSString *)orderId withCompletionHandler:(QBCompletionHandler)completionHandler {
    if (orderId == nil) {
        QBSafelyCallBlock(completionHandler, NO, nil);
        return NO;
    }
    
    return [self requestURLPath:kQueryOrderURL
                     withParams:@{@"orderId":orderId}
                responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
            {
            QBSafelyCallBlock(completionHandler, respStatus == QBURLResponseSuccess, respStatus == QBURLResponseSuccess ? self.response : errorMessage);
            }];
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(QBURLResponseHandler)responseHandler {
//    id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    
    NSString *decryptedResponse = [self decryptResponse:responseObject];
    self.response = decryptedResponse;
    QBLog(@"Manual activation response : %@", decryptedResponse);
    QBSafelyCallBlock(responseHandler, decryptedResponse.length>0?QBURLResponseSuccess:QBURLResponseFailedByInterface, decryptedResponse.length>0?nil:@"无该订单或者该笔订单未支付");
}
@end
