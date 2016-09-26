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

#import "YYKBanneredProgramModel.h"

@interface YYKHomeViewController () <UISearchBarDelegate>
@property (nonatomic) BOOL hasShownSpreadBanner;
@end

@implementation YYKHomeViewController
@synthesize programModel = _programModel;

DefineLazyPropertyInitialization(YYKBanneredProgramModel, programModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"category"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        
    }];
    [self.navigationController.navigationBar addSubview:self.searchBar];
    
    [self.view addSubview:self.layoutCollectionView];
    {
        [self.layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

    @weakify(self);
    [self.layoutCollectionView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadPrograms];
    }];
    [self.layoutCollectionView YYK_triggerPullToRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
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
