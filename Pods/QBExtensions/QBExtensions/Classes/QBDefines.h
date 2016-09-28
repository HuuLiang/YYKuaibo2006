//
//  QBMacros.h
//  Pods
//
//  Created by Sean Yue on 16/6/17.
//
//

#ifndef QBMacros_h
#define QBMacros_h

#ifdef  DEBUG
#define QBLog(fmt,...) {printf("%s\n", [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);}
#else
#define QBLog(...)
#endif

#define QBDefineLazyPropertyInitialization(propertyType, propertyName) \
-(propertyType *)propertyName { \
if (_##propertyName) { \
return _##propertyName; \
} \
_##propertyName = [[propertyType alloc] init]; \
return _##propertyName; \
}

#define QBSafelyCallBlock(block,...) \
if (block) block(__VA_ARGS__);

#define QBSafelyCallBlockAndRelease(block,...) \
if (block) { block(__VA_ARGS__); block = nil;};

#define kScreenHeight     [ [ UIScreen mainScreen ] bounds ].size.height
#define kScreenWidth      [ [ UIScreen mainScreen ] bounds ].size.width

typedef void (^QBAction)(id obj);
typedef void (^QBCompletionHandler)(BOOL success, id obj);

#endif /* QBMacros_h */
