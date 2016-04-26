//
//  YYKCardSlider.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/21.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYKCard.h"

@class YYKCardSlider;

@protocol YYKCardSliderDataSource <NSObject>

@required
- (NSUInteger)numberOfCardsInCardSlider:(YYKCardSlider *)slider;
- (YYKCard *)cardSlider:(YYKCardSlider *)slider cardAtIndex:(NSUInteger)index;

@end

@protocol YYKCardSliderDelegate <NSObject>

@optional
- (CGSize)cardSlider:(YYKCardSlider *)slider sizeOfCardAtIndex:(NSUInteger)index;
- (void)cardSlider:(YYKCardSlider *)slider didSelectCardAtIndex:(NSUInteger)index;

@end

@interface YYKCardSlider : UIView

@property (nonatomic,weak) id<YYKCardSliderDataSource> dataSource;
@property (nonatomic,weak) id<YYKCardSliderDelegate> delegate;
@property (nonatomic) CGFloat interCardSpacing;
@property (nonatomic,readonly) NSUInteger currentCardIndex;
@property (nonatomic) UIView *backgroundView;

- (void)reloadData;
//- (void)setCurrentCardIndex:(NSUInteger)currentCardIndex animated:(BOOL)animated;
- (YYKCard *)dequeReusableCardAtIndex:(NSUInteger)index;

@end
