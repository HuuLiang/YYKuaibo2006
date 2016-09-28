//
//  QBNetworkingConfiguration.h
//  Pods
//
//  Created by Sean Yue on 16/6/14.
//
//

#import <Foundation/Foundation.h>

@interface QBNetworkingConfiguration : NSObject

@property (nonatomic) NSString *channelNo;
@property (nonatomic) NSString *RESTAppId;
@property (nonatomic) NSNumber *RESTpV;

@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSString *standbyBaseURL;

@property (nonatomic) BOOL logEnabled DEPRECATED_ATTRIBUTE;

+ (instancetype)defaultConfiguration;

@end
