//
//  YYKHomeViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController.h"
#import "YYKHomeViewController+CollectionViewModel.h"
#import "YYKHomeViewController+SearchBar.h"
#import "YYKCategoryViewController.h"

#import "YYKBanneredProgramModel.h"
#import "YYKVersionUpdateModel.h"
#import "YYKVersionUpdateViewController.h"

@interface YYKHomeViewController () <UISearchBarDelegate>
@property (nonatomic) BOOL hasShownSpreadBanner;
@end

@implementation YYKHomeViewController
@synthesize programModel = _programModel;

DefineLazyPropertyInitialization(YYKBanneredProgramModel, programModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    [self examineUpdate];//检查更新
    @weakify(self);
    self.navigationItem.title = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[[UIImage imageNamed:@"category"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                style:UIBarButtonItemStylePlain
                                                                              handler:^(id sender)
    {
        @strongify(self);
        YYKCategoryViewController *categoryVC = [[YYKCategoryViewController alloc] init];
        [self.navigationController pushViewController:categoryVC animated:YES];
    }];
    [self.navigationController.navigationBar addSubview:self.searchBar];
    
    [self.view addSubview:self.layoutCollectionView];
    {
        [self.layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

    [self.layoutCollectionView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadPrograms];
    }];
    [self.layoutCollectionView YYK_triggerPullToRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    self.searchBar.hidden = NO;
////    if (self.searchBar.hidden) {
////        [UIView animateWithDuration:0.2 animations:^{
////            self.searchBar.hidden = NO;
////        }];
////    }
//}
- (void)examineUpdate {
    [[YYKVersionUpdateModel sharedModel] fetchLatestVersionWithCompletionHandler:^(BOOL success, id obj) {
        if (success) {
            YYKVersionUpdateInfo *info = obj;
            if (info.up.boolValue) {
                YYKVersionUpdateViewController *updateVC = [[YYKVersionUpdateViewController alloc] init];
                updateVC.linkUrl = info.linkUrl;
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:updateVC animated:YES completion:nil];
            }
            //            if (info.isForceToUpdate.boolValue) {
            //                [UIAlertView bk_showAlertViewWithTitle:@"系统更新"
            //                                               message:@"系统检测到新的版本，建议您升级到新的版本；如果您选择不升级，将影响到应用的使用。"
            //                                     cancelButtonTitle:@"取消"
            //                                     otherButtonTitles:@[@"确定"]
            //                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex)
            //                {
            //                    if (buttonIndex == 1) {
            //                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info.linkUrl]];
            //                    }
            //                }];
            //            }
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.searchBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchBar.hidden = YES;
}

- (void)loadPrograms {
    @weakify(self);
    [self.programModel fetchProgramsInSpace:YYKBanneredProgramSpaceHome withCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self.layoutCollectionView YYK_endPullToRefresh];
        
        if (success) {
            [self.layoutCollectionView reloadData];
            
            if (([YYKUtil launchSeq] >= 3 && [YYKUtil isNoVIP]) || [YYKUtil isAnyVIP]) {
                if (!self.hasShownSpreadBanner) {
                    [YYKUtil showSpreadBanner];
                    self.hasShownSpreadBanner = YES;
                }
            }
        }
    }];
}

- (void)onPaidNotification {
    [self reloadTrialSection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
