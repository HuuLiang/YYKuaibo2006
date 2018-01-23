//
//  YYKTagSearchViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKTagSearchViewController.h"
#import "YYKKeywordTagModel.h"
#import "YYKKeyword.h"
#import "YYKVideoCell.h"
#import "YYKVideoSectionHeader.h"

static NSString *const kTagSearchCellReusableIdentifier = @"TagSearchCellReusableIdentifier";

static NSString *const kTagSearchHeaderReusableIdentifier = @"TagSearchHeaderReusableIdentifier";

static const void *kTextLabelAssociatedKey = &kTextLabelAssociatedKey;
static const void *kImageViewAssociatedKey = &kImageViewAssociatedKey;

@interface YYKTagSearchViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) NSArray<YYKKeyword *> *searchedKeywords;
@property (nonatomic,retain) YYKKeywordTagModel *tagModel;

@end

@implementation YYKTagSearchViewController

DefineLazyPropertyInitialization(YYKKeywordTagModel, tagModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kTagSearchCellReusableIdentifier];
    
    [_layoutCV registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kTagSearchHeaderReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.view).offset(60);
        }];
    }
}

- (void)reloadData {
    [_layoutCV reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.searchedKeywords = [YYKKeyword allKeywords];
    [_layoutCV reloadData];
    
    [self reloadHotTags];
    
}

- (void)reloadHotTags {
    @weakify(self);
    [self.tagModel fetchTagsWithCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (success) {
            [self->_layoutCV reloadData];
        }
    }];
}

- (UILabel *)textLabelInCell:(UICollectionViewCell *)cell {
    UILabel *textLabel = objc_getAssociatedObject(cell, kTextLabelAssociatedKey);
    if (!textLabel) {
        textLabel = [[UILabel alloc] init];
        objc_setAssociatedObject(cell, kTextLabelAssociatedKey, textLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        textLabel.font = kMediumFont;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = kDefaultTextColor;
        [cell addSubview:textLabel];
        {
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell).insets(UIEdgeInsetsMake(0, 5, 0, 5));
            }];
        }
    }
    return textLabel;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(tagSearchViewControllerDidScroll:)]) {
        [self.delegate tagSearchViewControllerDidScroll:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagModel.fetchedTags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagSearchCellReusableIdentifier forIndexPath:indexPath];
    
    UILabel *textLabel = [self textLabelInCell:cell];
    if (indexPath.item < self.tagModel.fetchedTags.count) {
        NSString *tag = self.tagModel.fetchedTags[indexPath.item];
        textLabel.text = tag;
    } else {
        textLabel.text = nil;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kTagSearchHeaderReusableIdentifier forIndexPath:indexPath];
        
        UIImageView *imageView = objc_getAssociatedObject(headerView, kImageViewAssociatedKey);
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"section_title_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            objc_setAssociatedObject(headerView, kImageViewAssociatedKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            imageView.tintColor = kThemeColor;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [headerView addSubview:imageView];
            {
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(headerView);
                    make.left.equalTo(headerView).offset(5);
                    make.height.equalTo(headerView).multipliedBy(0.5);
                    make.width.equalTo(imageView.mas_height);
                }];
            }
        }
        
        UILabel *textLabel = objc_getAssociatedObject(headerView, kTextLabelAssociatedKey);
        if (!textLabel) {
            textLabel = [[UILabel alloc] init];
            objc_setAssociatedObject(headerView, kTextLabelAssociatedKey, textLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            textLabel.textColor = kDefaultTextColor;
            textLabel.font = kMediumFont;
            [headerView addSubview:textLabel];
            {
                [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(imageView.mas_right).offset(5);
                    make.centerY.equalTo(headerView);
                }];
            }
        }
        textLabel.text = @"热门搜索";
        return headerView;
        
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds)/3, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (self.tagModel.fetchedTags.count == 0) {
        return CGSizeZero;
    } else {
        return CGSizeMake(0, 45);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *textLabel = objc_getAssociatedObject(cell, kTextLabelAssociatedKey);
    if (textLabel.text.length == 0) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(tagSearchViewController:didSelectKeyword:)]) {
        [self.delegate tagSearchViewController:self didSelectKeyword:[YYKKeyword keywordWithText:textLabel.text isTag:YES]];
    }
}
@end
