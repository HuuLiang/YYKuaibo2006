//
//  YYKApplication.h
//  ShiWanSprite
//
//  Created by Sean Yue on 15/5/4.
//  Copyright (c) 2015年 Kuchuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYKApplication : NSObject
@property (readonly) NSString *applicationIdentifier;
@property (readonly) NSString *applicationDSID;
@property (readonly) NSString *applicationType;
@property (readonly) NSString *bundleVersion;
@property (readonly) BOOL isPurchasedReDownload;
@property (readonly) BOOL isInstalled;
@property (readonly) NSNumber *itemID;
@property (readonly) NSString *itemName;
@property (readonly) NSString *shortVersionString;
@property (readonly) NSString *sourceAppIdentifier;
@property (readonly) NSString *teamID;
@property (readonly) NSString *vendorName;

@property (readonly) BOOL valid;

+(instancetype)applicationFromApplicationProxy:(id)applicationProxy;
-(instancetype)initWithApplicationProxy:(id)applicationProxy;
@end
