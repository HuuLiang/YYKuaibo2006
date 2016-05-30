//
//  YYKHomeCollectionViewLayout.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeCollectionViewLayout.h"

static const CGFloat kLandscaleItemScale = 2;
static const CGFloat kPortaitItemScale = 7./9.;
static const CGFloat kHeaderHeight = 40;

typedef NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> LayoutAttributesDictionary;

@interface YYKHomeCollectionViewLayout ()

@property (nonatomic,retain) LayoutAttributesDictionary *itemLayoutAttributes;
@property (nonatomic,retain) LayoutAttributesDictionary *headerLayoutAttributes;

@property (nonatomic) CGSize collectionViewContentSize;
@end

@implementation YYKHomeCollectionViewLayout

DefineLazyPropertyInitialization(LayoutAttributesDictionary, itemLayoutAttributes)
DefineLazyPropertyInitialization(LayoutAttributesDictionary, headerLayoutAttributes)

- (instancetype)init {
    self = [super init];
    if (self) {
        _interItemSpacing = kDefaultCollectionViewInteritemSpace;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.itemLayoutAttributes removeAllObjects];
    [self.headerLayoutAttributes removeAllObjects];
    self.collectionViewContentSize = CGSizeZero;
    
    NSUInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return ;
    }
    
    CGRect lastFrame = CGRectMake(0, 0, self.collectionView.bounds.size.width, 0);
    for (NSUInteger section = 0; section < numberOfSections; ++section) {
        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        UIEdgeInsets sectionInsets = [self insetsForSection:section];
        
        UICollectionViewLayoutAttributes *headerLayoutAttribs;
        if (section >= YYKHomeSectionChannelOffset) {
            const CGFloat headerWidth = self.collectionView.bounds.size.width - sectionInsets.left - sectionInsets.right;
            
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            headerLayoutAttribs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
            headerLayoutAttribs.frame = CGRectMake(sectionInsets.left, CGRectGetMaxY(lastFrame)+sectionInsets.top+sectionInsets.bottom, headerWidth, kHeaderHeight);
            [self.headerLayoutAttributes setObject:headerLayoutAttribs forKey:headerIndexPath];
            lastFrame = headerLayoutAttribs.frame;
        }
    
        for (NSUInteger item = 0; item < numberOfItems; ++item) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *itemLayoutAttribs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGSize itemSize = [self sizeOfItemAtIndexPath:indexPath];
            if (item == 0) {
                itemLayoutAttribs.frame = CGRectMake(sectionInsets.left, CGRectGetMaxY(lastFrame)+(headerLayoutAttribs?0:sectionInsets.top), itemSize.width, itemSize.height);
            } else if (CGRectGetMaxX(lastFrame) + itemSize.width + self.interItemSpacing > self.collectionView.bounds.size.width) {
                if (indexPath.section >= YYKHomeSectionChannelOffset && indexPath.item == 2) {
                    itemLayoutAttribs.frame = CGRectMake(lastFrame.origin.x, CGRectGetMaxY(lastFrame)+self.interItemSpacing,
                                                     itemSize.width, itemSize.height);
                } else {
                    itemLayoutAttribs.frame = CGRectMake(sectionInsets.left, CGRectGetMaxY(lastFrame)+self.interItemSpacing,
                                                     itemSize.width, itemSize.height);
                }
            } else {
                itemLayoutAttribs.frame = CGRectMake(CGRectGetMaxX(lastFrame)+self.interItemSpacing, lastFrame.origin.y, itemSize.width, itemSize.height);
            }
            lastFrame = itemLayoutAttribs.frame;
            [self.itemLayoutAttributes setObject:itemLayoutAttribs forKey:indexPath];
        }
    }
    
    self.collectionViewContentSize = CGSizeMake(self.collectionView.bounds.size.width, CGRectGetMaxY(lastFrame));
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *headerLayoutAttribs = [self.headerLayoutAttributes.allValues bk_select:^BOOL(id obj) {
        UICollectionViewLayoutAttributes *attributes = obj;
        return CGRectIntersectsRect(rect, attributes.frame);
    }];
    
    NSArray *itemLayoutAttribs = [self.itemLayoutAttributes.allValues bk_select:^BOOL(id obj) {
        UICollectionViewLayoutAttributes *attributes = obj;
        return CGRectIntersectsRect(rect, attributes.frame);
    }];
    
    return [headerLayoutAttribs arrayByAddingObjectsFromArray:itemLayoutAttribs];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemLayoutAttributes[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return self.headerLayoutAttributes[indexPath];
    } else {
        return nil;
    }
}

- (CGSize)sizeOfItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets sectionInsets = [self insetsForSection:indexPath.section];
    const CGFloat fullWidth = CGRectGetWidth(self.collectionView.bounds) - sectionInsets.left - sectionInsets.right;
    const CGFloat halfWidth = (fullWidth - self.interItemSpacing)/2;
    
    CGSize itemSize = CGSizeZero;
    if (indexPath.section == YYKHomeSectionBanner) {
        itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), CGRectGetWidth(self.collectionView.bounds) / kLandscaleItemScale);
    } else if (indexPath.section == YYKHomeSectionTrial) {
        itemSize = CGSizeMake(halfWidth, halfWidth);
    } else {
        if (indexPath.item < 3) {
            const CGFloat item0Height = (2 * fullWidth - self.interItemSpacing) / (2 * kPortaitItemScale + 1);
            const CGFloat item0Width = item0Height * kPortaitItemScale;
            
            const CGFloat item12Size = (item0Height - self.interItemSpacing) / 2;
            itemSize = indexPath.item == 0 ? CGSizeMake(item0Width, item0Height) : CGSizeMake(item12Size, item12Size);
        } else {
            itemSize = CGSizeMake(halfWidth, halfWidth);
        }
    }
    return itemSize;
}

- (UIEdgeInsets)insetsForSection:(NSUInteger)section {
    if (section == YYKHomeSectionBanner) {
        return UIEdgeInsetsZero;
    }
    return UIEdgeInsetsMake(5, 5, 0, 5);
}
@end
