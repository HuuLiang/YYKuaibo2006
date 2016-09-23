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
#import "YYKVideoLibViewController.h"
#import "YYKVIPViewController.h"
#import "YYKSearchViewController.h"
#import "YYKActivateModel.h"
#import "YYKUserAccessModel.h"
#import "YYKSystemConfigModel.h"
#import "YYKAppSpreadBannerModel.h"
#import "MobClick.h"
#import "YYKVersionUpdateModel.h"
#import <QBNetworkingConfiguration.h>

@interface YYKAppDelegate () <UITabBarControllerDelegate>
@property (nonatomic,retain) UIViewController *rootViewController;
@end

@implementation YYKAppDelegate

- (UIWindow *)window {
    if (_window) {
        return _window;
    }
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor              = [UIColor whiteColor];
    
    
    return _window;
}

- (UIViewController *)rootViewController {
    if (_rootViewController) {
        return _rootViewController;
    }
    
    YYKHomeViewController *homeVC = [[YYKHomeViewController alloc] init];
    homeVC.title = @"AV爽片";
    
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:homeVC.title
                                                       image:[UIImage imageNamed:@"tabbar_home_normal"]
                                               selectedImage:[UIImage imageNamed:@"tabbar_home_selected"]];
    
    YYKVideoLibViewController *libVC = [[YYKVideoLibViewController alloc] init];
    libVC.title = @"AV片库";
    
    UINavigationController *channelNav = [[UINavigationController alloc] initWithRootViewController:libVC];
    channelNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:libVC.title
                                                          image:[UIImage imageNamed:@"tabbar_lib_normal"]
                                                  selectedImage:[UIImage imageNamed:@"tabbar_lib_selected"]];
    
    YYKVIPViewController *vipVC = [[YYKVIPViewController alloc] init];
    vipVC.title = kSVIPText;
    
    UINavigationController *vipNav = [[UINavigationController alloc] initWithRootViewController:vipVC];
    vipNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                      image:[UIImage imageNamed:@"tabbar_vip_normal"]
                                              selectedImage:[UIImage imageNamed:@"tabbar_vip_selected"]];
    vipNav.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    YYKSearchViewController *searchVC = [[YYKSearchViewController alloc] init];
    searchVC.title = @"AV热搜";
    
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    searchNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:searchVC.title
                                                         image:[UIImage imageNamed:@"tabbar_search_normal"]
                                                 selectedImage:[UIImage imageNamed:@"tabbar_search_selected"]];
    
    YYKMineViewController *mineVC = [[YYKMineViewController alloc] init];
    mineVC.title = @"我的AV";
    
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:mineVC.title
                                                       image:[UIImage imageNamed:@"tabbar_mine_normal"]
                                               selectedImage:[UIImage imageNamed:@"tabbar_mine_selected"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeNav, channelNav, vipNav, searchNav, mineNav];
    //    tabBarController.tabBar.translucent = NO;
    tabBarController.delegate = self;
    _rootViewController = tabBarController;
    return _rootViewController;
}

- (void)setupCommonStyles {
//    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
//    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
//    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setSelectedImageTintColor:kThemeColor];
    [[UITabBar appearance] setTintColor:kThemeColor];
//    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBarTintColor:kThemeColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.],
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    if ([UITextField respondsToSelector:@selector(appearanceWhenContainedInInstancesOfClasses:)]) {
        [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor darkGrayColor]];
    } else {
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor darkGrayColor]];
    }
    
//    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithHexString:@"#ff226f"]];
//    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
//                                                   forState:UIControlStateNormal|UIControlStateSelected];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   //thisVC.navigationController.navigationBar.translucent = NO;
                                   thisVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:nil];
                               } error:nil];
    
    [UIViewController aspect_hookSelector:@selector(hidesBottomBarWhenPushed)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo)
    {
        UIViewController *thisVC = [aspectInfo instance];
        BOOL hidesBottomBarWhenPushed = YES;
        if (thisVC.navigationController.viewControllers.count == 0 || thisVC.navigationController.viewControllers.firstObject == thisVC) {
            hidesBottomBarWhenPushed = NO;
        }
        [[aspectInfo originalInvocation] setReturnValue:&hidesBottomBarWhenPushed];
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [QBNetworkingConfiguration defaultConfiguration].baseURL = YYK_BASE_URL;
    [QBNetworkingConfiguration defaultConfiguration].channelNo = YYK_CHANNEL_NO;
    [QBNetworkingConfiguration defaultConfiguration].RESTpV = YYK_REST_PV;
    [QBNetworkingConfiguration defaultConfiguration].RESTAppId = YYK_REST_APP_ID;
#ifdef DEBUG
    [QBNetworkingConfiguration defaultConfiguration].logEnabled = YES;
#endif
    
    [YYKUtil accumateLaunchSeq];
    [[QBPaymentManager sharedManager] registerPaymentWithAppId:YYK_REST_APP_ID
                                                     paymentPv:YYK_PAYMENT_PV
                                                     channelNo:YYK_CHANNEL_NO
                                                     urlScheme:@"comqskuaiboapppayurlscheme"];
    [[YYKErrorHandler sharedHandler] initialize];
    [self setupMobStatistics];
    [self setupCommonStyles];
//    [self registerUserNotification];
    [[QBNetworkInfo sharedInfo] startMonitoring];
    
    BOOL requestedSystemConfig = NO;
#ifdef YYK_IMAGE_TOKEN_ENABLED
    NSString *imageToken = [YYKUtil imageToken];
    if (imageToken) {
        [[SDWebImageManager sharedManager].imageDownloader setValue:imageToken forHTTPHeaderField:@"Referer"];
        self.window.rootViewController = self.rootViewController;
        [self.window makeKeyAndVisible];
    } else {
        self.window.rootViewController = [[UIViewController alloc] init];
        [self.window makeKeyAndVisible];
        
        [self.window beginProgressingWithTitle:@"更新系统配置..." subtitle:nil];
        requestedSystemConfig = [[YYKSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
            [self.window endProgressing];
            
            if (success) {
                NSString *fetchedToken = [YYKSystemConfigModel sharedModel].imageToken;
                [YYKUtil setImageToken:fetchedToken];
                if (fetchedToken) {
                    [[SDWebImageManager sharedManager].imageDownloader setValue:fetchedToken forHTTPHeaderField:@"Referer"];
                }
                
            }
            
            self.window.rootViewController = self.rootViewController;
            
            NSUInteger statsTimeInterval = 180;
            if ([YYKSystemConfigModel sharedModel].loaded && [YYKSystemConfigModel sharedModel].statsTimeInterval > 0) {
                statsTimeInterval = [YYKSystemConfigModel sharedModel].statsTimeInterval;
            }
            [[YYKStatsManager sharedManager] scheduleStatsUploadWithTimeInterval:statsTimeInterval];
        }];
    }
#else 
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
#endif
//    YYKLaunchView *launchView = [[YYKLaunchView alloc] init];
//    [launchView show];
    
    if (![YYKUtil isRegistered]) {
        [[YYKActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
            if (success) {
                [YYKUtil setRegisteredWithUserId:userId];
                [[YYKUserAccessModel sharedModel] requestUserAccess];
                
                [[YYKUtil allUnsuccessfulPaymentInfos] enumerateObjectsUsingBlock:^(YYKPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.userId == nil) {
                        obj.userId = userId;
                        [obj save];
                    }
                }];
            }
        }];
    } else {
        [[YYKUserAccessModel sharedModel] requestUserAccess];
    }
    
    if (!requestedSystemConfig) {
        [[YYKSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
            
#ifdef YYK_IMAGE_TOKEN_ENABLED
            if (success) {
                [YYKUtil setImageToken:[YYKSystemConfigModel sharedModel].imageToken];
            }
#endif
            NSUInteger statsTimeInterval = 180;
            if ([YYKSystemConfigModel sharedModel].loaded && [YYKSystemConfigModel sharedModel].statsTimeInterval > 0) {
                statsTimeInterval = [YYKSystemConfigModel sharedModel].statsTimeInterval;
            }
            [[YYKStatsManager sharedManager] scheduleStatsUploadWithTimeInterval:statsTimeInterval];
        }];
    }
    
    [[YYKVideoTokenManager sharedManager] requestTokenWithCompletionHandler:nil];
    [[YYKAppSpreadBannerModel sharedModel] fetchAppSpreadWithCompletionHandler:nil];
    [[YYKVersionUpdateModel sharedModel] fetchLatestVersionWithCompletionHandler:^(BOOL success, id obj) {
        if (success) {
            YYKVersionUpdateInfo *info = obj;
            if (info.isForceToUpdate.boolValue) {
                [UIAlertView bk_showAlertViewWithTitle:@"系统更新"
                                               message:@"系统检测到新的版本，建议您升级到新的版本；如果您选择不升级，将影响到应用的使用。"
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@[@"确定"]
                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                {
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info.linkUrl]];
                    }
                }];
            }
        }
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
    [[QBPaymentManager sharedManager] applicationWillEnterForeground:application];
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
    [[QBPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [[QBPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[QBPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}
#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [[YYKStatsManager sharedManager] statsTabIndex:tabBarController.selectedIndex subTabIndex:[YYKUtil currentSubTabPageIndex] forClickCount:1];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [[YYKStatsManager sharedManager] statsStopDurationAtTabIndex:tabBarController.selectedIndex subTabIndex:[YYKUtil currentSubTabPageIndex]];
    return YES;
}
@end
