//
//  QBURLResponse.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "QBURLResponse.h"
#import <objc/runtime.h>
#import "QBDefines.h"
#import "NSObject+Properties.h"

const NSUInteger kSuccessResponseCode = 100;

@implementation QBURLResponseCode

@end

@implementation QBURLResponse

- (Class)responseCodeClass {
    return [QBURLResponseCode class];
}

- (void)parseResponseWithDictionary:(NSDictionary *)dic {
    [self parseDataWithDictionary:dic inInstance:self];
}

- (void)parseDataWithDictionary:(NSDictionary *)dic inInstance:(id)instance {
    if (!dic || !instance) {
        return ;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSArray *properties = [NSObject propertiesOfClass:[instance class]];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = key;
        NSString *setPropertyName = propertyName;
        
        NSString *const kNameMappingProperty = @"QB_propertyOfParsing:";
        if ([instance respondsToSelector:NSSelectorFromString(kNameMappingProperty)]) {
            setPropertyName = [instance performSelector:NSSelectorFromString(kNameMappingProperty) withObject:propertyName];
        }
        
        id value = obj;
        
        if ([setPropertyName isEqualToString:@"code"] && [value isKindOfClass:[NSDictionary class]]) {
            setPropertyName = @"responseCode";
            propertyName = setPropertyName;
        }
        
        if (![properties containsObject:setPropertyName]) {
            return ;
        }
        
        if ([value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSNumber class]]) {
            [instance setValue:value forKey:setPropertyName];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            id property = [instance valueForKey:setPropertyName];
            Class subclass = [property class];
            if (!subclass) {
                NSString *classPropertyName = [propertyName stringByAppendingString:@"Class"];
                if ([instance respondsToSelector:NSSelectorFromString(classPropertyName)]) {
                    subclass = [instance valueForKey:classPropertyName];
                }
            }
            
            if (!subclass) {
                NSString *const kClassSelectorName = @"QB_classOfProperty:";
                if ([instance respondsToSelector:NSSelectorFromString(kClassSelectorName)]) {
                    subclass = [instance performSelector:NSSelectorFromString(kClassSelectorName) withObject:setPropertyName];
                }
            }
            
            id subinstance = [[subclass alloc] init];
            [instance setValue:subinstance forKey:setPropertyName];
            
            [self parseDataWithDictionary:(NSDictionary *)value inInstance:subinstance];
        } else if ([value isKindOfClass:[NSArray class]]) {
            Class subclass = [instance valueForKey:[propertyName stringByAppendingString:@"ElementClass"]];
            if (!subclass) {
                QBLog(@"JSON Parsing Warning: cannot find element class of property: %@ in class: %@\n", propertyName, [[instance class] description])
                return;
            }
            
            if (subclass == [NSString class] || subclass == [NSNumber class]) {
                [instance setValue:value forKey:setPropertyName];
                return ;
            }
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [instance setValue:arr forKey:setPropertyName];
            
            for (id subobj in (NSArray *)value) {
                if ([subobj isKindOfClass:[NSDictionary class]]) {
                    id subinstance = [[subclass alloc] init];
                    [arr addObject:subinstance];
                    [self parseDataWithDictionary:(NSDictionary *)subobj inInstance:subinstance];
                } else if ([subobj isKindOfClass:[NSString class]]) {
                    [arr addObject:subobj];
                }
            }
            
//            for (NSDictionary *subDic in (NSArray *)value) {
//                id subinstance = [[subclass alloc] init];
//                [arr addObject:subinstance];
//                [self parseDataWithDictionary:subDic inInstance:subinstance];
//            }
        }
    }];
//    [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        
//    }];
#pragma clang diagnostic pop
}

@end
