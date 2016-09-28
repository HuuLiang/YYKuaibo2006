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

@interface YYKHomeViewController () <UISearchBarDelegate>
@property (nonatomic) BOOL hasShownSpreadBanner;
@end

@implementation YYKHomeViewController
@synthesize programModel = _programModel;

DefineLazyPropertyInitialization(YYKBanneredProgramModel, programModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
