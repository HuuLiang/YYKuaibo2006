//
//  YYKPhotoBrowser.m
//  YYKuaibo
//
//  Created by Sean Yue on 2016/9/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKPhotoBrowser.h"
#import "YYKPhotoUrlModel.h"

@interface YYKPhotoBrowser () <MWPhotoBrowserDelegate>
@property (nonatomic,retain) YYKPhotoUrlModel *urlModel;
@property (nonatomic,retain) NSArray<MWPhoto *> *photos;
@end

@implementation YYKPhotoBrowser

DefineLazyPropertyInitialization(YYKPhotoUrlModel, urlModel)

- (instancetype)initWithPhotoProgram:(YYKProgram *)program {
    self = [super initWithDelegate:self];
    if (self) {
        _program = program;
        self.displayActionButton = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.program.title;
    
    [self loadUrls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = kBarColor;
}

- (void)loadUrls {
    @weakify(self);
    [self.urlModel fetchUrlListWithProgramId:self.program.programId pageNo:1 pageSize:999 completionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (success) {

            NSArray<YYKProgramUrl *> *urls = obj;
            NSMutableArray *photos = [NSMutableArray array];
            [urls enumerateObjectsUsingBlock:^(YYKProgramUrl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:obj.url]];
                photo.caption = obj.title;
                [photos addObject:photo];
            }];
            self.photos = photos;
            [self reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return index < self.photos.count ? self.photos[index] : nil;
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [NSString stringWithFormat:@"第%ld张（共%ld张）", (unsigned long)(index+1), self.photos.count];
    }
    return nil;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    id<MWPhoto> photo = [self photoBrowser:photoBrowser photoAtIndex:index];
    if ([photo caption]) {
        MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
        captionView.barTintColor = kBarColor;
        return captionView;
    }
    return nil;
}
@end
