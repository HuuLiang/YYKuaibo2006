//
//  QBNetworkingConfiguration.m
//  QBNetworking
//
//  Created by Sean Yue on 16/6/14.
//
//

#import "QBNetworkingConfiguration.h"

@implementation QBNetworkingConfiguration

+ (instancetype)defaultConfiguration {
    static QBNetworkingConfiguration *_defaultConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultConfiguration = [[self alloc] init];
    });
    return _defaultConfiguration;
}

@end
