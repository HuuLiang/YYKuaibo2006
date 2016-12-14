//
//  QBURLRequest.m
//  QBNetworking
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "QBURLRequest.h"
#import "QBNetworkingConfiguration.h"
#import "AFNetworking.h"
#import "RACEXTScope.h"
#import "QBDefines.h"

NSString *const kQBNetworkingErrorNotification = @"com.iqu8.qbnetworking.errornotification";
NSString *const kQBNetworkingErrorCodeKey = @"com.iqu8.qbnetworking.errorcodekey";
NSString *const kQBNetworkingErrorMessageKey = @"com.iqu8.qbnetworking.errormessagekey";

@interface QBURLRequest ()
@property (nonatomic,retain) AFHTTPSessionManager *requestSessionManager;
@property (nonatomic,retain) NSURLSessionDataTask *requestSessionTask;

@property (nonatomic,retain) AFHTTPSessionManager *standbyRequestSessionManager;
@property (nonatomic,retain) NSURLSessionDataTask *standbyRequestSessionTask;

-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(id)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(QBURLResponseHandler)responseHandler;
@end

@implementation QBURLRequest
@synthesize configuration = _configuration;

- (instancetype)initWithConfiguration:(QBNetworkingConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
    }
    return self;
}

- (QBNetworkingConfiguration *)configuration {
    if (_configuration) {
        return _configuration;
    }
    
    return [QBNetworkingConfiguration defaultConfiguration];
}

+ (Class)responseClass {
    return [QBURLResponse class];
}

- (NSURL *)baseURL {
    return [NSURL URLWithString:self.configuration.baseURL];
}

- (NSURL *)standbyBaseURL {
    return [NSURL URLWithString:self.configuration.standbyBaseURL];
}

- (BOOL)shouldPostErrorNotification {
    return YES;
}

- (QBURLRequestMethod)requestMethod {
    return QBURLGetRequest;
}

- (AFHTTPSessionManager *)requestSessionManager {
    if (_requestSessionManager) {
        return _requestSessionManager;
    }
    
    _requestSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
    return _requestSessionManager;
}

- (AFHTTPSessionManager *)standbyRequestSessionManager {
    if (_standbyRequestSessionManager) {
        return _standbyRequestSessionManager;
    }
    
    _standbyRequestSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self standbyBaseURL]];
    return _standbyRequestSessionManager;
}

- (NSTimeInterval)requestTimeInterval {
    return 60;
}

-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(id)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(QBURLResponseHandler)responseHandler
{
    if (urlPath.length == 0) {
        if (responseHandler) {
            responseHandler(QBURLResponseFailedByParameter, nil);
        }
        return NO;
    }
    
    QBLog(@"Requesting %@ !\nwith parameters: %@\n", urlPath, params);

    @weakify(self);
    self.response = [[[[self class] responseClass] alloc] init];
    
    void (^success)(NSURLSessionDataTask *,id) = ^(NSURLSessionDataTask *task, id responseObject) {
        @strongify(self);
        
        QBLog(@"Response for %@ : %@\n", urlPath, responseObject);
        
        [self processResponseObject:responseObject withResponseHandler:responseHandler];
    };
    
    void (^failure)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        QBLog(@"Error for %@ : %@\n", urlPath, error.localizedDescription);
        
        if (shouldNotifyError) {
            if ([self shouldPostErrorNotification]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kQBNetworkingErrorNotification
                                                                    object:self
                                                                  userInfo:@{kQBNetworkingErrorCodeKey:@(QBURLResponseFailedByNetwork),
                                                                             kQBNetworkingErrorMessageKey:error.localizedDescription}];
            }
        }
        
        if (responseHandler) {
            responseHandler(QBURLResponseFailedByNetwork,error.localizedDescription);
        }
    };
    
    
    if (isStandBy) {
        self.standbyRequestSessionManager.requestSerializer.timeoutInterval = self.requestTimeInterval;
        self.standbyRequestSessionTask = [self.standbyRequestSessionManager GET:urlPath parameters:params progress:nil success:success failure:failure];
    } else {
        self.requestSessionManager.requestSerializer.timeoutInterval = self.requestTimeInterval;
        if (self.requestMethod == QBURLGetRequest) {
            self.requestSessionTask = [self.requestSessionManager GET:urlPath parameters:params progress:nil success:success failure:failure];
        } else {
            self.requestSessionTask = [self.requestSessionManager POST:urlPath parameters:params progress:nil success:success failure:failure];
        }
    }
    return YES;
}

- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(id)params responseHandler:(QBURLResponseHandler)responseHandler {
    BOOL useStandbyRequest = standbyUrlPath.length > 0;
    
    if (useStandbyRequest && [QBNetworkingConfiguration defaultConfiguration].useStaticBaseUrl) {
        BOOL success = [self requestURLPath:standbyUrlPath
                                 withParams:params
                                  isStandby:YES
                          shouldNotifyError:YES
                            responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
                        {
                            if (responseHandler) {
                                responseHandler(respStatus,errorMessage);
                            }
                        }];
        return success;
    }
    
    BOOL success = [self requestURLPath:urlPath
                             withParams:params
                              isStandby:NO
                      shouldNotifyError:!useStandbyRequest
                        responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
    {
        if (useStandbyRequest && respStatus == QBURLResponseFailedByNetwork) {
            [self requestURLPath:standbyUrlPath withParams:params isStandby:YES shouldNotifyError:YES responseHandler:responseHandler];
        } else {
            if (responseHandler) {
                responseHandler(respStatus,errorMessage);
            }
        }
    }];
    return success;
}

-(BOOL)requestURLPath:(NSString *)urlPath withParams:(id)params responseHandler:(QBURLResponseHandler)responseHandler
{
    return [self requestURLPath:urlPath standbyURLPath:nil withParams:params responseHandler:responseHandler];
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(QBURLResponseHandler)responseHandler {
    QBURLResponseStatus status = QBURLResponseNone;
    NSString *errorMessage;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if ([self.response isKindOfClass:[QBURLResponse class]]) {
            QBURLResponse *urlResp = self.response;
            [urlResp parseResponseWithDictionary:responseObject];
            
            status = urlResp.success.boolValue ? QBURLResponseSuccess : QBURLResponseFailedByInterface;
            errorMessage = (status == QBURLResponseSuccess) ? nil : [NSString stringWithFormat:@"ResultCode: %@", urlResp.resultCode];
        } else {
            status = QBURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON dictionary.\n";
        }
    } else if ([responseObject isKindOfClass:[NSString class]]) {
        if ([self.response isKindOfClass:[NSString class]]) {
            self.response = responseObject;
            status = QBURLResponseSuccess;
        } else {
            status = QBURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON string.\n";
        }
    } else {
        errorMessage = @"Error data structure of response from interface!\n";
        status = QBURLResponseFailedByInterface;
    }
    
    if (status != QBURLResponseSuccess) {
        QBLog(@"Error message : %@\n", errorMessage);
        
        if ([self shouldPostErrorNotification]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kQBNetworkingErrorNotification
                                                                object:self
                                                              userInfo:@{kQBNetworkingErrorCodeKey:@(status),
                                                                         kQBNetworkingErrorMessageKey:errorMessage}];
        }
    }
    
    if (responseHandler) {
        responseHandler(status, errorMessage);
    }

}
@end
