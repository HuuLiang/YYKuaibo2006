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
//#import "YYKSearchViewController.h"
#import "YYKRankingViewController.h"
#import "YYKActivateModel.h"
#import "YYKUserAccessModel.h"
#import "YYKSystemConfigModel.h"
#import "YYKAppSpreadBannerModel.h"
#import "MobClick.h"
#import "YYKVersionUpdateModel.h"
#import <QBNetworkingConfiguration.h>
#import <QBPaymentConfig.h>

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
    homeVC.title = @"大片";
    
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:homeVC.title
                                                       image:[UIImage imageNamed:@"tabbar_home_normal"]
                                               selectedImage:[UIImage imageNamed:@"tabbar_home_selected"]];
    
    YYKVideoLibViewController *libVC = [[YYKVideoLibViewController alloc] init];
    libVC.title = @"片库";
    
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
    
    YYKRankingViewController *rankingVC = [[YYKRankingViewController alloc] init];
    rankingVC.title = @"排行榜";
    
    UINavigationController *rankingNav = [[UINavigationController alloc] initWithRootViewController:rankingVC];
    rankingNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:rankingVC.title
                                                         image:[UIImage imageNamed:@"tabbar_ranking_normal"]
                                                 selectedImage:[UIImage imageNamed:@"tabbar_ranking_selected"]];
    
    YYKMineViewController *mineVC = [[YYKMineViewController alloc] init];
    mineVC.title = @"我的";
    
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:mineVC.title
                                                       image:[UIImage imageNamed:@"tabbar_mine_normal"]
                                               selectedImage:[UIImage imageNamed:@"tabbar_mine_selected"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeNav, channelNav, vipNav, rankingNav, mineNav];
//    tabBarController.tabBar.translucent = NO;
    tabBarController.delegate = self;
    _rootViewController = tabBarController;
    return _rootViewController;
}

- (void)setupCommonStyles {
//    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
//    [[UITabBar appearance] setSelectedImageTintColor:kThemeColor];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:kBarColor];
//    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBarTintColor:kBarColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.],
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    if ([UITextField respondsToSelector:@selector(appearanceWhenContainedInInstancesOfClasses:)]) {
        [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor lightTextColor]];
    } else {
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor lightTextColor]];
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
    
    [YYKUtil accumateLaunchSeq];
//    [[QBPaymentManager sharedManager] usePaymentConfigInTestServer:YES];//测试支付
    [YYKUtil setDefaultPrice];
    [[QBPaymentManager sharedManager] registerPaymentWithAppId:YYK_REST_APP_ID
                                                     paymentPv:YYK_PAYMENT_PV
                                                     channelNo:YYK_CHANNEL_NO
                                                     urlScheme:@"comqskuaiboapppayurlscheme"
                                                     defaultConfig:[self setDefaultPaymentConfig]];
    [[YYKErrorHandler sharedHandler] initialize];
    [self setupMobStatistics];
    [self setupCommonStyles];
//    [self registerUserNotification];
    [[QBNetworkInfo sharedInfo] startMonitoring];
    
//    [QBNetworkInfo sharedInfo].reachabilityChangedAction = ^(BOOL reachable) {
//        if (reachable && ![YYKSystemConfigModel sharedModel].loaded) {
//            [self fetchSystemConfigWithCompletionHandler:nil];
//        }
//    };
    [QBNetworkInfo sharedInfo].reachabilityChangedAction = ^(BOOL reachable) {
        if (reachable && ![YYKSystemConfigModel sharedModel].loaded) {
            [self fetchSystemConfigWithCompletionHandler:nil];
        }
        if (reachable && ![YYKUtil isRegistered]) {
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

                    [[YYKVideoTokenManager sharedManager] requestTokenWithCompletionHandler:nil];
                }
            }];
        } else {
            [[YYKUserAccessModel sharedModel] requestUserAccess];
            [[YYKVideoTokenManager sharedManager] requestTokenWithCompletionHandler:nil];
        }
        if ([QBNetworkInfo sharedInfo].networkStatus <= QBNetworkStatusNotReachable && (![YYKUtil isRegistered] || ![YYKSystemConfigModel sharedModel].loaded)) {
            if ([YYKUtil isIpad] || [UIDevice currentDevice].systemVersion.integerValue < 8.0) {
                [UIAlertView bk_showAlertViewWithTitle:@"请检查您的网络连接!" message:nil cancelButtonTitle:@"确认" otherButtonTitles:nil handler:nil];
            }else{
                [UIAlertView bk_showAlertViewWithTitle:@"很抱歉!" message:@"您的应用未连接到网络,请检查您的网络设置" cancelButtonTitle:@"稍后" otherButtonTitles:@[@"设置"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }];
            }}
    };

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
        requestedSystemConfig = [self fetchSystemConfigWithCompletionHandler:^(BOOL success) {
            [self.window endProgressing];
            self.window.rootViewController = self.rootViewController;
        }];
    }
#else 
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
#endif
//    YYKLaunchView *launchView = [[YYKLaunchView alloc] init];
//    [launchView show];
    
//    if (![YYKUtil isRegistered]) {
//        [[YYKActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
//            if (success) {
//                [YYKUtil setRegisteredWithUserId:userId];
//                [[YYKUserAccessModel sharedModel] requestUserAccess];
//                
//                [[YYKUtil allUnsuccessfulPaymentInfos] enumerateObjectsUsingBlock:^(YYKPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if (obj.userId == nil) {
//                        obj.userId = userId;
//                        [obj save];
//                    }
//                }];
//            }
//        }];
//    } else {
//        [[YYKUserAccessModel sharedModel] requestUserAccess];
//    }
    
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
    
//    [[YYKVideoTokenManager sharedManager] requestTokenWithCompletionHandler:nil];
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

- (BOOL)fetchSystemConfigWithCompletionHandler:(void (^)(BOOL success))completionHandler {
    return [[YYKSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSString *fetchedToken = [YYKSystemConfigModel sharedModel].imageToken;
            [YYKUtil setImageToken:fetchedToken];
            if (fetchedToken) {
                [[SDWebImageManager sharedManager].imageDownloader setValue:fetchedToken forHTTPHeaderField:@"Referer"];
            }
            
        }
        
        NSUInteger statsTimeInterval = 180;
        [[YYKStatsManager sharedManager] scheduleStatsUploadWithTimeInterval:statsTimeInterval];
        
        SafelyCallBlock(completionHandler, success);
    }];
}

- (QBPaymentConfig *)setDefaultPaymentConfig {
    QBPaymentConfig *config = [[QBPaymentConfig alloc] init];
    
    QBPaymentConfigDetail *configDetails = [[QBPaymentConfigDetail alloc] init];
    //爱贝默认配置
    QBIAppPayConfig * iAppPayConfig = [[QBIAppPayConfig alloc] init];
    iAppPayConfig.appid = @"3006339410";
    iAppPayConfig.privateKey = @"MIICWwIBAAKBgQCHEQCLCZujWicF6ClEgHx4L/OdSHZ1LdKi/mzPOIa4IRfMOS09qDNV3+uK/zEEPu1DgO5Cl1lsm4xpwIiOqdXNRxLE9PUfgRy4syiiqRfofAO7w4VLSG4S0VU5F+jqQzKM7Zgp3blbc5BJ5PtKXf6zP3aCAYjz13HHH34angjg0wIDAQABAoGASOJm3aBoqSSL7EcUhc+j2yNdHaGtspvwj14mD0hcgl3xPpYYEK6ETTHRJCeDJtxiIkwfxjVv3witI5/u0LVbFmd4b+2jZQ848BHGFtZFOOPJFVCylTy5j5O79mEx0nJN0EJ/qadwezXr4UZLDIaJdWxhhvS+yDe0e0foz5AxWmkCQQDhd9U1uUasiMmH4WvHqMfq5l4y4U+V5SGb+IK+8Vi03Zfw1YDvKrgv1Xm1mdzYHFLkC47dhTm7/Ko8k5Kncf89AkEAmVtEtycnSYciSqDVXxWtH1tzsDeIMz/ZlDGXCAdUfRR2ZJ2u2jrLFunoS9dXhSGuERU7laasK0bDT4p0UwlhTwJAVF+wtPsRnI1PxX6xA7WAosH0rFuumax2SFTWMLhGduCZ9HEhX97/sD7V3gSnJWRsDJTasMEjWtrxpdufvPOnDQJAdsYPVGMItJPq5S3n0/rv2Kd11HdOD5NWKsa1mMxEjZN5lrfhoreCb7694W9pI31QWX6+ZUtvcR0fS82KBn3vVQJAa0fESiiDDrovKHBm/aYXjMV5anpbuAa5RJwCqnbjCWleZMwHV+8uUq9+YMnINZQnvi+C62It4BD+KrJn5q4pwg==";
    iAppPayConfig.publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCbNQyxdpLeMwE0QMv/dB3Jn1SRqYE/u3QT3ig2uXu4yeaZo4f7qJomudLKKOgpa8+4a2JAPRBSueDpiytR0zN5hRZKImeZAu2foSYkpBqnjb5CRAH7roO7+ervoizg6bhAEx2zlltV9wZKQZ0Di5wCCV+bMSEXkYqfASRplYUvHwIDAQAB";
    iAppPayConfig.notifyUrl = @"http://phas.zcqcmj.com/pd-has/notifyIpay.json";
    iAppPayConfig.waresid = @(1);
    configDetails.iAppPayConfig = iAppPayConfig;
    
    //    //海豚默认配置
    //    QBHTPayConfig *htpayConfig = [[QBHTPayConfig alloc] init];
    //    htpayConfig.mchId = @"10014";
    //    htpayConfig.key = @"55f4f728b7a01c2e57a9f767fd34cb8e";
    //    htpayConfig.appid = @"wxdea87ffa75dfb0fa";
    //    htpayConfig.notifyUrl = @"http://phas.zcqcmj.com/pd-has/notifyHtPay.json";
    //    htpayConfig.payType = @"z";
    //    configDetails.htpayConfig = htpayConfig;
    
    //WJPAY
    QBWJPayConfig *wjPayCofig = [[QBWJPayConfig alloc] init];
    wjPayCofig.mchId = @"50000009";
    wjPayCofig.notifyUrl = @"http://phas.zcqcmj.com/pd-has/notifyWujism.json";
    wjPayCofig.signKey = @"B0C65DF81AA7EA85";
    configDetails.wjPayConfig = wjPayCofig;
    
    //支付方式
    QBPaymentConfigSummary *payConfig = [[QBPaymentConfigSummary alloc] init];
    payConfig.alipay = @"IAPPPAY";
    payConfig.wechat = @"WUJI";
    
    config.configDetails = configDetails;
    config.payConfig = payConfig;
    
    [config setAsCurrentConfig];
    return config;
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
