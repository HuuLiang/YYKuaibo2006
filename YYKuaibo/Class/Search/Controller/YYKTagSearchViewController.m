//
//  YYKTagSearchViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKTagSearchViewController.h"
#import "YYKTagSearchFooterView.h"
#import "YYKKeywordTagModel.h"
#import "YYKKeyword.h"

static NSString *const kTagSearchCellReusableIdentifier = @"TagSearchCellReusableIdentifier";
static NSString *const kSearchErrorCellReusableIdentifier = @"SearchErrorCellReusableIdentifier";

static NSString *const kTagSearchHeaderReusableIdentifier = @"TagSearchHeaderReusableIdentifier";
static NSString *const kTagSearchFooterReusableIdentifier = @"TagSearchFooterReusableIdentifier";

static const void *kTextLabelAssociatedKey = &kTextLabelAssociatedKey;
static const void *kImageViewAssociatedKey = &kImageViewAssociatedKey;

static const NSUInteger kUnexpandedItemCount = 9;

typedef NS_ENUM(NSUInteger, YYKTagSearchSection) {
    YYKErrorSection,
    YYKTagSection,
    YYKHistorySection,
    YYKTagSearchSectionCount
};

@interface YYKTagSearchViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) NSArray<YYKKeyword *> *searchedKeywords;
@property (nonatomic,retain) YYKKeywordTagModel *tagModel;
@property (nonatomic) BOOL shouldExpandTags;

@end

@implementation YYKTagSearchViewController

DefineLazyPropertyInitialization(YYKKeywordTagModel, tagModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kTagSearchCellReusableIdentifier];
    [_layoutCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSearchErrorCellReusableIdentifier];
    [_layoutCV registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kTagSearchHeaderReusableIdentifier];
    [_layoutCV registerClass:[YYKTagSearchFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kTagSearchFooterReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
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

- (void)reloadSearchedKeywords {
    self.searchedKeywords = [YYKKeyword allKeywords];
    
    NSUInteger numberOfSections = [_layoutCV numberOfSections];
    if (numberOfSections > YYKHistorySection) {
        [_layoutCV reloadSections:[NSIndexSet indexSetWithIndex:YYKHistorySection]];
    }
}

- (void)reloadHotTags {
    @weakify(self);
    [self.tagModel fetchTagsWithCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (success) {
            self.shouldExpandTags = NO;
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
        [cell addSubview:textLabel];
        {
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell).insets(UIEdgeInsetsMake(0, 5, 0, 5));
            }];
        }
    }
    return textLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return YYKTagSearchSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == YYKHistorySection) {
        return (self.searchedKeywords.count + 2) / 3 * 3;
    } else if (section == YYKErrorSection) {
        if ([self.delegate respondsToSelector:@selector(searchErrorMessageInTagSearchViewController:)]) {
            if ([self.delegate searchErrorMessageInTagSearchViewController:self].length > 0) {
                return 1;
            }
        }
        return 0;
    } else if (section == YYKTagSection) {
        NSUInteger items = (self.tagModel.fetchedTags.count + 2)/3*3;
        if (self.shouldExpandTags || self.tagModel.fetchedTags.count <= kUnexpandedItemCount) {
            return items;
        } else {
            return kUnexpandedItemCount;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKErrorSection) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSearchErrorCellReusableIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        
        UILabel *textLabel = [self textLabelInCell:cell];
        textLabel.numberOfLines = 4;
        
        if ([self.delegate respondsToSelector:@selector(searchErrorMessageInTagSearchViewController:)]) {
            textLabel.attributedText = [self.delegate searchErrorMessageInTagSearchViewController:self];
        } else {
            textLabel.attributedText = nil;
        }
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagSearchCellReusableIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        
        UILabel *textLabel = [self textLabelInCell:cell];
        if (indexPath.section == YYKHistorySection) {
            if (indexPath.item < self.searchedKeywords.count) {
                YYKKeyword *keyword = self.searchedKeywords[indexPath.item];
                textLabel.text = keyword.text;
            } else {
                textLabel.text = nil;
            }
        } else if (indexPath.section == YYKTagSection) {
            if (indexPath.item < self.tagModel.fetchedTags.count) {
                NSString *tag = self.tagModel.fetchedTags[indexPath.item];
                textLabel.text = tag;
            } else {
                textLabel.text = nil;
            }
        }
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kTagSearchHeaderReusableIdentifier forIndexPath:indexPath];
        
        UIImageView *imageView = objc_getAssociatedObject(headerView, kImageViewAssociatedKey);
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"section_title_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            objc_setAssociatedObject(headerView, kImageViewAssociatedKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            imageView.tintColor = [UIColor darkPink];
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
            
            textLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
            textLabel.font = kMediumFont;
            [headerView addSubview:textLabel];
            {
                [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(imageView.mas_right).offset(5);
                    make.centerY.equalTo(headerView);
                }];
            }
        }
        textLabel.text = indexPath.section == YYKTagSection ? @"热门搜索" : @"搜索历史";
        return headerView;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        YYKTagSearchFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kTagSearchFooterReusableIdentifier forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor whiteColor];
        
        if (indexPath.section == YYKHistorySection) {
            footerView.title = @"清空记录";
            
            @weakify(self);
            footerView.tapAction = ^(id obj) {
                [UIAlertView bk_showAlertViewWithTitle:@"是否确认清空搜索记录？"
                                               message:nil
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     if (buttonIndex == 1) {
                         [YYKKeyword deleteAllKeywords];
                         
                         @strongify(self);
                         [self reloadSearchedKeywords];
                     }
                 }];
            };
        } else if (indexPath.section == YYKTagSection) {
            footerView.image = [UIImage imageNamed:@"search_tag_expand"];
            
            if (self.shouldExpandTags) {
                footerView.imageTransform = CGAffineTransformMakeRotation(M_PI);
            } else {
                footerView.imageTransform = CGAffineTransformIdentity;
            }
            
            @weakify(self);
            footerView.tapAction = ^(id obj) {
                @strongify(self);
                self.shouldExpandTags = !self.shouldExpandTags;
                [self->_layoutCV reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            };
        }
        return footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKErrorSection) {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), 100);
    } else {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds)/3, 44);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == YYKErrorSection) {
        return CGSizeZero;
    } else if (section == YYKTagSection) {
        if (self.tagModel.fetchedTags.count == 0) {
            return CGSizeZero;
        }
    }
    return CGSizeMake(0, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == YYKHistorySection) {
        return self.searchedKeywords.count > 0 ? CGSizeMake(0, 35):CGSizeZero;
    } else if (section == YYKTagSection) {
        if (self.tagModel.fetchedTags.count <= kUnexpandedItemCount) {
            return CGSizeZero;
        } else {
            return CGSizeMake(0, 35);
        }
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *textLabel = objc_getAssociatedObject(cell, kTextLabelAssociatedKey);
    if (textLabel.text.length == 0) {
        return ;
    }
    
    if (indexPath.section == YYKErrorSection) {
        if ([self.delegate respondsToSelector:@selector(tagSearchViewController:didSelectErrorMessage:)]) {
            [self.delegate tagSearchViewController:self didSelectErrorMessage:textLabel.text];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(tagSearchViewController:didSelectKeyword:)]) {
            BOOL isTag = indexPath.section == YYKTagSection;
            if (indexPath.section == YYKHistorySection && indexPath.item < self.searchedKeywords.count  ) {
                YYKKeyword *keyword = self.searchedKeywords[indexPath.item];
                isTag = keyword.isTag;
            }
            [self.delegate tagSearchViewController:self didSelectKeyword:[YYKKeyword keywordWithText:textLabel.text isTag:isTag]];
        }
    }
    
}
@end
