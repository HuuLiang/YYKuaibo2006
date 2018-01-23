//
//  QBOrderQueryModel.h
//  Pods
//
//  Created by Sean Yue on 16/9/21.
//
//

#import "QBPaymentURLRequest.h"
#import "QBDefines.h"

@interface QBOrderQueryModel : QBPaymentURLRequest

- (BOOL)queryOrder:(NSString *)orderId withCompletionHandler:(QBCompletionHandler)completionHandler;

@end
