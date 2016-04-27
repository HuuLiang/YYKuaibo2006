//
//  YYKApplicationManager.m
//  ShiWanSprite
//
//  Created by Sean Yue on 15/5/4.
//  Copyright (c) 2015年 Kuchuan. All rights reserved.
//

#import "YYKApplicationManager.h"
#import <objc/runtime.h>

#define SafelyPerformSelector(instance, sel, ret) \
if (instance && sel && [instance respondsToSelector:sel]) { \
ret = [instance performSelector:sel]; \
}

@interface YYKApplicationManager ()
@property (nonatomic,readonly,retain) id applicationWorkspace;

-(NSArray *)wrappedApplicationsFromRawApplications:(NSArray *)rawApps;
@end

@implementation YYKApplicationManager

+(instancetype)defaultManager {
    static YYKApplicationManager *defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
        if (!LSApplicationWorkspace_class) {
            return;
        }
        NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
        defaultManager = [[YYKApplicationManager alloc] initWithApplicationWorkspace:workspace];
#pragma clang diagnostic pop
    });
    return defaultManager;
}

-(instancetype)initWithApplicationWorkspace:(id)appWorkspace {
    self = [super init];
    if (self) {
        _applicationWorkspace = appWorkspace;
    }
    return self;
}

-(NSArray *)wrappedApplicationsFromRawApplications:(NSArray *)rawApps {
    if (!rawApps) {
        return nil;
    }
    
    NSMutableArray *wrappedApps = [NSMutableArray array];
    for (id rawApp in rawApps) {
        YYKApplication *wrappedApp = [YYKApplication applicationFromApplicationProxy:rawApp];
        if (wrappedApp) {
            [wrappedApps addObject:wrappedApp];
        }
    }
    return wrappedApps.count > 0 ? wrappedApps : nil;
}

-(NSArray *)allApplications {
    NSArray *rawApps;
    SafelyPerformSelector(_applicationWorkspace, @selector(allApplications), rawApps);
    return [self wrappedApplicationsFromRawApplications:rawApps];
}

-(NSArray *)allInstalledApplications {
    NSArray *rawApps;
    SafelyPerformSelector(_applicationWorkspace, @selector(allInstalledApplications), rawApps);
    return [self wrappedApplicationsFromRawApplications:rawApps];
}

-(NSArray *)allApplicationIdentifiers {
    NSMutableArray *appIds = [NSMutableArray array];
    NSArray *allApplications = [self allApplications];
    for (YYKApplication *application in allApplications) {
        [appIds addObject:application.applicationIdentifier];
    }
    return appIds.count > 0 ? appIds : nil;
}

-(NSArray *)allInstalledAppIdentifiers {
    NSMutableArray *appIds = [NSMutableArray array];
    NSArray *allInstalledApps = [self allInstalledApplications];
    for (YYKApplication *app in allInstalledApps) {
        [appIds addObject:app.applicationIdentifier];
    }
    return appIds.count > 0 ? appIds : nil;
}
@end
