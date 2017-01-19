//
//  QBURLRequest.h
//  QBNetworking
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBURLResponse.h"

@class QBNetworkingConfiguration;

typedef NS_ENUM(NSUInteger, QBURLResponseStatus) {
    QBURLResponseSuccess,
    QBURLResponseFailedByInterface,
    QBURLResponseFailedByNetwork,
    QBURLResponseFailedByParsing,
    QBURLResponseFailedByParameter,
    QBURLResponseNone
};

typedef NS_ENUM(NSUInteger, QBURLRequestMethod) {
    QBURLGetRequest,
    QBURLPostRequest
};

typedef void (^QBURLResponseHandler)(QBURLResponseStatus respStatus, NSString *errorMessage);

@interface QBURLRequest : NSObject

@property (nonatomic,retain,readonly) QBNetworkingConfiguration *configuration;
@property (nonatomic,retain) id response;

@property (nonatomic) NSTimeInterval requestTimeInterval;

- (instancetype)initWithConfiguration:(QBNetworkingConfiguration *)configuration;

+ (Class)responseClass;  // override this method to provide a custom class to be used when instantiating instances of QBURLResponse
- (NSURL *)baseURL; // override this method to provide a custom base URL to be used
- (NSURL *)standbyBaseURL; // override this method to provide a custom standby base URL to be used

- (BOOL)shouldPostErrorNotification;
- (QBURLRequestMethod)requestMethod;

- (BOOL)requestURLPath:(NSString *)urlPath withParams:(id)params responseHandler:(QBURLResponseHandler)responseHandler;

- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(QBURLResponseHandler)responseHandler;

// For subclass pre/post processing response object
- (void)processResponseObject:(id)responseObject withResponseHandler:(QBURLResponseHandler)responseHandler;

@end

extern NSString *const kQBNetworkingErrorNotification;
extern NSString *const kQBNetworkingErrorCodeKey;
extern NSString *const kQBNetworkingErrorMessageKey;
