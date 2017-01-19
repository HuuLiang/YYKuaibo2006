//
//  QBNetworkingConfiguration.h
//  Pods
//
//  Created by Sean Yue on 16/6/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBURLEncryptedType) {
    QBURLEncryptedTypeOriginal = 0, // iOS视频包原加密方式
    QBURLEncryptedTypeNew           //目前iOS仅在交友项目用到的加密方式
};

@interface QBNetworkingConfiguration : NSObject

@property (nonatomic) NSString *channelNo;
@property (nonatomic) NSString *RESTAppId;
@property (nonatomic) NSNumber *RESTpV;

@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSString *standbyBaseURL;

@property (nonatomic) BOOL logEnabled DEPRECATED_ATTRIBUTE;
@property (nonatomic) BOOL useStaticBaseUrl;

@property (nonatomic) QBURLEncryptedType encryptedType;

//@property (nonatomic) 

+ (instancetype)defaultConfiguration;

@end
