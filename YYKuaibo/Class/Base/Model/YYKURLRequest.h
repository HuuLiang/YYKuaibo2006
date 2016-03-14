//
//  YYKURLRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYKURLResponse.h"

typedef NS_ENUM(NSUInteger, YYKURLResponseStatus) {
    YYKURLResponseSuccess,
    YYKURLResponseFailedByInterface,
    YYKURLResponseFailedByNetwork,
    YYKURLResponseFailedByParsing,
    YYKURLResponseFailedByParameter,
    YYKURLResponseNone
};

typedef NS_ENUM(NSUInteger, YYKURLRequestMethod) {
    YYKURLGetRequest,
    YYKURLPostRequest
};
typedef void (^YYKURLResponseHandler)(YYKURLResponseStatus respStatus, NSString *errorMessage);

@interface YYKURLRequest : NSObject

@property (nonatomic,retain) id response;

+ (Class)responseClass;  // override this method to provide a custom class to be used when instantiating instances of YYKURLResponse
+ (BOOL)shouldPersistURLResponse;
- (NSURL *)baseURL; // override this method to provide a custom base URL to be used
- (NSURL *)standbyBaseURL; // override this method to provide a custom standby base URL to be used

- (BOOL)shouldPostErrorNotification;
- (YYKURLRequestMethod)requestMethod;

- (BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(YYKURLResponseHandler)responseHandler;

- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(YYKURLResponseHandler)responseHandler;

// For subclass pre/post processing response object
- (void)processResponseObject:(id)responseObject withResponseHandler:(YYKURLResponseHandler)responseHandler;

@end
