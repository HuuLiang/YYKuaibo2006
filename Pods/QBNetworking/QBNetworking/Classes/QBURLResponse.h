//
//  QBURLResponse.h
//  QBNetworking
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QBResponseParsable <NSObject>

@optional
- (Class)QB_classOfProperty:(NSString *)propName;
- (NSString *)QB_propertyOfParsing:(NSString *)parsingName;

@end

@interface QBURLResponse : NSObject

@property (nonatomic) NSNumber *success;
@property (nonatomic) NSString *resultCode;


- (void)parseResponseWithDictionary:(NSDictionary *)dic;

@end
