//
//  YYKAppDelegate.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKAppDelegate.h"
#import "YYKHomeViewController.h"
#import "YYKSideMenuViewController.h"
#import "YYKActivateModel.h"
#import "YYKUserAccessModel.h"
#import "YYKPaymentModel.h"
#import "YYKSystemConfigModel.h"
#import "MobClick.h"

@interface YYKAppDelegate ()

@end

@implementation YYKAppDelegate

- (UIWindow *)window {
    if (_window) {
        return _window;
    }
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor              = [UIColor whiteColor];
    
    YYKHomeViewController *homeVC = [[YYKHomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    YYKSideMenuViewController *sideMenuVC = [[YYKSideMenuViewController alloc] init];
    UINavigationController *sideMenuNav = [[UINavigationController alloc] initWithRootViewController:sideMenuVC];
//    sideMenuNav.navigationBarHidden = YES;
    
    RESideMenu *sideMenu = [[RESideMenu alloc] initWithContentViewController:homeNav
                                                      leftMenuViewController:sideMenuNav
                                                     rightMenuViewController:nil];
    sideMenu.delegate = sideMenuVC;
    sideMenu.scaleContentView = NO;
    sideMenu.scaleBackgroundImageView = NO;
    sideMenu.scaleMenuView = NO;
    sideMenu.fadeMenuView = NO;
    sideMenu.parallaxEnabled = NO;
    sideMenu.bouncesHorizontally = NO;
    sideMenu.contentViewShadowEnabled = NO;
//    sideMenu.contentViewShadowOffset = CGSizeMake(2.0, 0.0f);
//    sideMenu.contentViewShadowOpacity = 0.8;
//    sideMenu.contentViewShadowColor = [UIColor whiteColor];
    sideMenu.contentViewInPortraitOffsetCenterX = kScreenWidth/2;
    _window.rootViewController = sideMenu;
    return _window;
}

- (void)setupCommonStyles {
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   thisVC.navigationController.navigationBar.translucent = NO;
                                   thisVC.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.95 alpha:1];
                                   thisVC.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.]};
                                   
                                   thisVC.navigationController.navigationBar.tintColor = [UIColor blackColor];
                                   thisVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:nil];
                               } error:nil];
    
    //    [UINavigationController aspect_hookSelector:@selector(preferredStatusBarStyle)
    //                                    withOptions:AspectPositionInstead
    //                                     usingBlock:^(id<AspectInfo> aspectInfo){
    //                                         UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
    //                                         [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
    //                                     } error:nil];
    //
    //    [UIViewController aspect_hookSelector:@selector(preferredStatusBarStyle)
    //                              withOptions:AspectPositionInstead
    //                               usingBlock:^(id<AspectInfo> aspectInfo){
    //                                   UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
    //                                   [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
    //                               } error:nil];
    
    [UINavigationController aspect_hookSelector:@selector(shouldAutorotate)
                                    withOptions:AspectPositionInstead
                                     usingBlock:^(id<AspectInfo> aspectInfo)
    {
        UINavigationController *thisNav = [aspectInfo instance];
        BOOL autoRotate = [thisNav.topViewController shouldAutorotate];
        [[aspectInfo originalInvocation] setReturnValue:&autoRotate];
     } error:nil];
    
    [UINavigationController aspect_hookSelector:@selector(supportedInterfaceOrientations)
                                    withOptions:AspectPositionInstead
                                     usingBlock:^(id<AspectInfo> aspectInfo)
    {
         UINavigationController *thisNav = [aspectInfo instance];
         NSUInteger result = [thisNav.topViewController supportedInterfaceOrientations];
         [[aspectInfo originalInvocation] setReturnValue:&result];
     } error:nil];
    
}

- (void)setupMobStatistics {
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    [MobClick setCrashReportEnabled:NO];
    NSString *bundleVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if (bundleVersion) {
        [MobClick setAppVersion:bundleVersion];
    }
    [MobClick startWithAppkey:YYK_UMENG_APP_ID reportPolicy:BATCH channelId:YYK_CHANNEL_NO];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[YYKPaymentManager sharedManager] setup];
    [[YYKErrorHandler sharedHandler] initialize];
    [self setupMobStatistics];
    [self setupCommonStyles];
    [self.window makeKeyAndVisible];
    
    if (![YYKUtil isRegistered]) {
        [[YYKActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
            if (success) {
                [YYKUtil setRegisteredWithUserId:userId];
                [[YYKUserAccessModel sharedModel] requestUserAccess];
            }
        }];
    } else {
        [[YYKUserAccessModel sharedModel] requestUserAccess];
    }
    
    [[YYKPaymentModel sharedModel] startRetryingToCommitUnprocessedOrders];
    [[YYKSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        if (!success) {
            return ;
        }
        
        if ([YYKSystemConfigModel sharedModel].startupInstall.length == 0
            || [YYKSystemConfigModel sharedModel].startupPrompt.length == 0) {
            return ;
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[YYKSystemConfigModel sharedModel].startupInstall]];
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (![YYKUtil isPaid]) {
        [[YYKPaymentManager sharedManager] checkPayment];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[YYKPaymentManager sharedManager] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [[YYKPaymentManager sharedManager] handleOpenURL:url];
    return YES;
}
@end
