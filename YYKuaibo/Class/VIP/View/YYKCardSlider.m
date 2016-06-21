//
//  YYKCardSlider.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/21.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKCardSlider.h"

typedef NS_ENUM(NSUInteger, YYKCardPosition) {
    YYKCardPositionRear,
    YYKCardPositionFront
};

@interface YYKCardSlider () <UIScrollViewDelegate>
{
    UIScrollView *_contentView;
}
@property (nonatomic,retain) NSMutableDictionary<NSNumber *, YYKCard *> *displayingCards;
@property (nonatomic,retain) NSMutableArray<YYKCard *> *reusableCards;
@end

@implementation YYKCardSlider

DefineLazyPropertyInitialization(NSMutableDictionary, displayingCards)
DefineLazyPropertyInitialization(NSMutableArray, reusableCards)

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _interCardSpacing = 25;
    
    _contentView = [[UIScrollView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.delegate = self;
    _contentView.pagingEnabled = YES;
    _contentView.clipsToBounds = NO;
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.showsVerticalScrollIndicator = NO;
    [self addSubview:_contentView];
    {
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.75);
            make.height.equalTo(self).multipliedBy(1);
        }];
    }
}

- (YYKCard *)dequeReusableCardAtIndex:(NSUInteger)index {
    YYKCard *card = [self.displayingCards objectForKey:@(index)];
    if (card) {
        return card;
    }
    
    card = self.reusableCards.firstObject;
    if (card) {
        [self.reusableCards removeObject:card];
        return card;
    }
    
    card = [[YYKCard alloc] init];
    card.layer.cornerRadius = 10;
    card.layer.masksToBounds = YES;
    @weakify(self);
    [card bk_whenTapped:^{
        @strongify(self);
        [self notifyDelegateDidSelectCardAtIndex:self.currentCardIndex];
    }];
    return card;
}

- (void)reloadData {
    _contentView.contentOffset = CGPointZero;
    _contentView.contentSize = CGSizeZero;
    [self removeAllDisplayingCards];
    
    // Load cards from beginning until the card exceeds the bounds of content view
    NSUInteger cardIndex = 0;
    NSUInteger numberOfCards = [self askDataSourceForNumberOfCards];
    YYKCard *addedCard;
    while (CGRectGetMaxX(addedCard.frame) < CGRectGetWidth(_contentView.bounds) && cardIndex < numberOfCards) {
        addedCard = [self addDisplayingCardInPosition:YYKCardPositionRear];
    }
}

#pragma mark - Property Setter/Getter

- (void)setBackgroundView:(UIView *)backgroundView {
    if (backgroundView == _backgroundView) {
        return ;
    }
    
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    
    [self insertSubview:backgroundView atIndex:0];
    {
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

- (NSUInteger)currentCardIndex {
    return _contentView.contentOffset.x / _contentView.bounds.size.width;
}

#pragma mark - Card Manipulation

- (NSUInteger)cardIndexInPosition:(YYKCardPosition)position {
    NSArray<NSNumber *> *displayingCardIndexes = [self.displayingCards.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    if (displayingCardIndexes.count == 0) {
        return NSNotFound;
    }
    
    NSUInteger index = position == YYKCardPositionFront ? displayingCardIndexes.firstObject.unsignedIntegerValue : displayingCardIndexes.lastObject.unsignedIntegerValue;
    return index;
}

- (YYKCard *)cardInPosition:(YYKCardPosition)position {
    NSUInteger cardIndex = [self cardIndexInPosition:position];
    if (cardIndex == NSNotFound) {
        return nil;
    }
    
    return self.displayingCards[@(cardIndex)];
}

- (YYKCard *)addDisplayingCardInPosition:(YYKCardPosition)position {
    NSUInteger cardIndexToAdd = NSNotFound;
    NSUInteger refCardIndex = [self cardIndexInPosition:position];
    if (refCardIndex == NSNotFound) {
        cardIndexToAdd = 0;
    }
    else if (position == YYKCardPositionRear) {
        if (refCardIndex < [self askDataSourceForNumberOfCards] - 1) {
            cardIndexToAdd = refCardIndex + 1;
        }
    } else if (position == YYKCardPositionFront) {
        if (refCardIndex > 0) {
            cardIndexToAdd = refCardIndex - 1;
        }
    }
    
    if (cardIndexToAdd == NSNotFound) {
        return nil;
    }
    
    // Add displaying card to content view
    YYKCard *card = [self askDataSourceForCardAtIndex:cardIndexToAdd];
    [_contentView addSubview:card];
    
    // Layout
    CGSize cardSize = [self askDelegateForSizeOfCardAtIndex:cardIndexToAdd];
    card.bounds = CGRectMake(0, 0, cardSize.width, cardSize.height);
    
    YYKCard *referenceCard = [self cardInPosition:position];
    if (referenceCard == nil) {
        CGPoint centerPoint = [self convertPoint:_contentView.center toView:_contentView];
        card.center = CGPointMake(self.interCardSpacing/2+cardSize.width/2, centerPoint.y);
    } else if (position == YYKCardPositionRear) {
        card.center = CGPointMake(CGRectGetMaxX(referenceCard.frame) + self.interCardSpacing + cardSize.width/2, referenceCard.center.y);
    } else if (position == YYKCardPositionFront) {
        card.center = CGPointMake(referenceCard.frame.origin.x - self.interCardSpacing - cardSize.width/2, referenceCard.center.y);
    }
    // Expand content size
    BOOL isAddToLast = [self.displayingCards.allKeys bk_all:^BOOL(id obj) {
        NSUInteger existingCardIndex = ((NSNumber *)obj).unsignedIntegerValue;
        return existingCardIndex < cardIndexToAdd;
    }];
    if (isAddToLast) {
        _contentView.contentSize = CGSizeMake(CGRectGetMaxX(card.frame)+self.interCardSpacing/2, _contentView.bounds.size.height);
    }
    
    [self.displayingCards setObject:card forKey:@(cardIndexToAdd)];
    
    [self reuseInvisibleCards];
    
    
    return card;
}

//- (void)addDisplayingCard:(YYKCard *)card atIndex:(NSUInteger)index {
//    if (!card) {
//        return ;
//    }
//    
//    [_contentView addSubview:card];
//    
//    BOOL isAddToLast = [self.displayingCards.allKeys bk_all:^BOOL(id obj) {
//        NSUInteger existingCardIndex = ((NSNumber *)obj).unsignedIntegerValue;
//        return existingCardIndex < index;
//    }];
//    if (isAddToLast) {
//        _contentView.contentSize = CGSizeMake(CGRectGetMaxX(card.frame)+self.interCardSpacing/2, _contentView.bounds.size.height);
//    }
//    
//    [self.displayingCards setObject:card forKey:@(index)];
//}

- (void)reuseInvisibleCards {
    [self.displayingCards enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, YYKCard * _Nonnull obj, BOOL * _Nonnull stop) {
        CGRect frameOnContainerView = [obj convertRect:obj.bounds toView:self];
        if (!CGRectContainsRect(self.bounds, frameOnContainerView) && !CGRectIntersectsRect(self.bounds, frameOnContainerView)) {
            [self reuseDisplayingCardAtIndex:key.unsignedIntegerValue];
        }
    }];
}

- (void)reuseDisplayingCardAtIndex:(NSUInteger)index {
    YYKCard *reusableCard = self.displayingCards[@(index)];
    if (reusableCard) {
        [reusableCard removeFromSuperview];
        reusableCard.frame = CGRectZero;
        [self.displayingCards removeObjectForKey:@(index)];
        [self.reusableCards addObject:reusableCard];
    }
}

//- (void)removeDisplayingCardInPosition:(YYKCardPosition)position {
//    YYKCard *reusableCard = self.displayingCards.count < 3 ? nil : [self cardInPosition:position];
//    if (reusableCard) {
//        [reusableCard removeFromSuperview];
//        reusableCard.frame = CGRectZero;
//        
//        NSUInteger cardIndex = [self cardIndexInPosition:position];
//        [self.displayingCards removeObjectForKey:@(cardIndex)];
//        [self.reusableCards addObject:reusableCard];
//    }
//}

- (void)removeAllDisplayingCards {
    [self.displayingCards enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, YYKCard * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj.frame = CGRectZero;
    }];
    [self.reusableCards addObjectsFromArray:self.displayingCards.allValues];
    [self.displayingCards removeAllObjects];
}

#pragma mark - Hit Test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        hitView = _contentView;
    }
    return hitView;
}

#pragma mark - DataSource/Delegate Helper Method

- (YYKCard *)askDataSourceForCardAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(cardSlider:cardAtIndex:)]) {
        return [self.dataSource cardSlider:self cardAtIndex:index];
    }
    return nil;
}

- (NSUInteger)askDataSourceForNumberOfCards {
    if ([self.dataSource respondsToSelector:@selector(numberOfCardsInCardSlider:)]) {
        return [self.dataSource numberOfCardsInCardSlider:self];
    }
    return 0;
}

- (CGSize)askDelegateForSizeOfCardAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(cardSlider:sizeOfCardAtIndex:)]) {
        return [self.delegate cardSlider:self sizeOfCardAtIndex:index];
    } else {
        const CGFloat cardWidth = _contentView.bounds.size.width - self.interCardSpacing;
        return CGSizeMake(cardWidth, cardWidth * 9./7.);
    }
    return CGSizeZero;
}

- (void)notifyDelegateDidSelectCardAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(cardSlider:didSelectCardAtIndex:)]) {
        [self.delegate cardSlider:self didSelectCardAtIndex:index];
    }
}

- (void)notifyDelegateDidEndSliding {
    if ([self.delegate respondsToSelector:@selector(cardSliderDidEndSliding:)]) {
        [self.delegate cardSliderDidEndSliding:self];
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    YYKCard *rearCard = [self cardInPosition:YYKCardPositionRear];
    CGRect rearCardFrameOnContainer = [rearCard convertRect:rearCard.bounds toView:self];
    if (CGRectContainsRect(self.bounds, rearCardFrameOnContainer)) {// || CGRectIntersectsRect(self.bounds, rearCardFrameOnContainer)) {
        [self addDisplayingCardInPosition:YYKCardPositionRear];
    }
    
    YYKCard *frontCard = [self cardInPosition:YYKCardPositionFront];
    CGRect frontCardFrameOnContainer = [frontCard convertRect:frontCard.bounds toView:self];
    if (frontCardFrameOnContainer.origin.x - self.interCardSpacing > self.bounds.origin.x) {
        [self addDisplayingCardInPosition:YYKCardPositionFront];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self notifyDelegateDidEndSliding];
}
@end
