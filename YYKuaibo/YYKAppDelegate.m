//
//  YYKAppDelegate.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKAppDelegate.h"
#import "YYKHomeViewController.h"
#import "YYKMineViewController.h"
#import "YYKChannelViewController.h"
#import "YYKVIPViewController.h"
#import "YYKSpreadViewController.h"
#import "YYKActivateModel.h"
#import "YYKUserAccessModel.h"
#import "YYKPaymentModel.h"
#import "YYKSystemConfigModel.h"
#import "YYKAppSpreadBannerModel.h"
#import "MobClick.h"
#import "YYKLaunchView.h"

@interface YYKAppDelegate () <UITabBarDelegate>

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
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                       image:[UIImage imageNamed:@"tabbar_home_normal"]
                                               selectedImage:nil];
    
    YYKChannelViewController *channelVC = [[YYKChannelViewController alloc] init];
    channelVC.title = @"频道";
    
    UINavigationController *channelNav = [[UINavigationController alloc] initWithRootViewController:channelVC];
    channelNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:channelVC.title
                                                          image:[UIImage imageNamed:@"tabbar_channel_normal"]
                                                  selectedImage:nil];
    
    YYKVIPViewController *vipVC = [[YYKVIPViewController alloc] init];
    vipVC.title = @"黑金VIP";
    
    UINavigationController *vipNav = [[UINavigationController alloc] initWithRootViewController:vipVC];
    vipNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                      image:[[UIImage imageNamed:@"tabbar_vip_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                              selectedImage:[[UIImage imageNamed:@"tabbar_vip_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    vipNav.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    YYKSpreadViewController *spreadVC = [[YYKSpreadViewController alloc] init];
    spreadVC.title = @"精品";
    
    UINavigationController *spreadNav = [[UINavigationController alloc] initWithRootViewController:spreadVC];
    spreadNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:spreadVC.title
                                                         image:[UIImage imageNamed:@"tabbar_spread_normal"]
                                                 selectedImage:nil];
    
    YYKMineViewController *mineVC = [[YYKMineViewController alloc] init];
    mineVC.title = @"我的";
    
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:mineVC.title
                                                           image:[UIImage imageNamed:@"tabbar_mine_normal"]
                                                   selectedImage:nil];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeNav, channelNav, vipNav, spreadNav, mineNav];
    tabBarController.tabBar.translucent = NO;
    _window.rootViewController = tabBarController;
    return _window;
}

- (void)setupCommonStyles {
    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#222222"]];
//    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor darkPink]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#222222"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithHexString:@"#ff226f"]];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                                   forState:UIControlStateNormal|UIControlStateSelected];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   thisVC.navigationController.navigationBar.translucent = NO;
                                   thisVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:nil];
                               } error:nil];
    
    [UINavigationController aspect_hookSelector:@selector(preferredStatusBarStyle)
                                    withOptions:AspectPositionInstead
                                     usingBlock:^(id<AspectInfo> aspectInfo){
                                         UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                         [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
                                     } error:nil];

    [UIViewController aspect_hookSelector:@selector(preferredStatusBarStyle)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                   [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
                               } error:nil];
    
    [UITabBarController aspect_hookSelector:@selector(shouldAutorotate)
                                withOptions:AspectPositionInstead
                                 usingBlock:^(id<AspectInfo> aspectInfo){
                                     UITabBarController *thisTabBarVC = [aspectInfo instance];
                                     UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                     
                                     BOOL autoRotate = NO;
                                     if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                         autoRotate = [((UINavigationController *)selectedVC).topViewController shouldAutorotate];
                                     } else {
                                         autoRotate = [selectedVC shouldAutorotate];
                                     }
                                     [[aspectInfo originalInvocation] setReturnValue:&autoRotate];
                                 } error:nil];
    
    [UITabBarController aspect_hookSelector:@selector(supportedInterfaceOrientations)
                                withOptions:AspectPositionInstead
                                 usingBlock:^(id<AspectInfo> aspectInfo){
                                     UITabBarController *thisTabBarVC = [aspectInfo instance];
                                     UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                     
                                     NSUInteger result = 0;
                                     if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                         result = [((UINavigationController *)selectedVC).topViewController supportedInterfaceOrientations];
                                     } else {
                                         result = [selectedVC supportedInterfaceOrientations];
                                     }
                                     [[aspectInfo originalInvocation] setReturnValue:&result];
                                 } error:nil];
    
}

- (void)setupMobStatistics {
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    NSString *bundleVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if (bundleVersion) {
        [MobClick setAppVersion:bundleVersion];
    }
    [MobClick startWithAppkey:YYK_UMENG_APP_ID reportPolicy:BATCH channelId:YYK_CHANNEL_NO];
    
}

- (void)registerUserNotification {
    if (NSClassFromString(@"UIUserNotificationSettings")) {
        UIUserNotificationType notiType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:notiType categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notiSettings];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [YYKUtil accumateLaunchSeq];
    [[YYKPaymentManager sharedManager] setup];
    [[YYKErrorHandler sharedHandler] initialize];
    [self setupMobStatistics];
    [self setupCommonStyles];
    [self registerUserNotification];
    [self.window makeKeyAndVisible];
    
    YYKLaunchView *launchView = [[YYKLaunchView alloc] init];
    [launchView show];
    
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
    
    [[YYKAppSpreadBannerModel sharedModel] fetchAppSpreadWithCompletionHandler:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([YYKUtil isAllVIPs]) {
        return ;
    }
    
    UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        DLog(@"Application expired background task!");
        [application endBackgroundTask:bgTask];
    }];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[YYKLocalNotificationManager sharedManager] scheduleLocalNotificationInEnteringBackground];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[YYKPaymentManager sharedManager] processPaymentInEnteringForeground];
//    if (![YYKUtil isAllVIPs]) {
//        [[YYKPaymentManager sharedManager] checkPayment];
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DLog(@"receive local notification");
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
