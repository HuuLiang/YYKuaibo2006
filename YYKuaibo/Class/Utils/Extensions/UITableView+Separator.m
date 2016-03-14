//
//  UITableView+Separator.m
//  YuePaoBa
//
//  Created by Sean Yue on 15/10/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "UITableView+Separator.h"

static void *kUpperSeparatorAssociatedKey = &kUpperSeparatorAssociatedKey;
static void *kLowerSeparatorAssociatedKey = &kLowerSeparatorAssociatedKey;
//static void *kAspectTokenAssociatedKey = &kAspectTokenAssociatedKey;
static void *kHasRowSeparatorAssociatedKey = &kHasRowSeparatorAssociatedKey;
static void *kHasSectionBorderAssociatedKey = &kHasSectionBorderAssociatedKey;

@interface UITableViewCell (Separator)
@property (nonatomic,retain) UIView *upperSeparator;
@property (nonatomic,retain) UIView *lowerSeparator;

- (UIView *)addUpperSeparatorWithColor:(UIColor *)color insets:(UIEdgeInsets)insets;
- (UIView *)addLowerSeparatorWithColor:(UIColor *)color insets:(UIEdgeInsets)insets;
@end

@implementation UITableViewCell (Separator)

- (UIView *)upperSeparator {
    return objc_getAssociatedObject(self, kUpperSeparatorAssociatedKey);
}

- (void)setUpperSeparator:(UIView *)upperSeparator {
    objc_setAssociatedObject(self, kUpperSeparatorAssociatedKey, upperSeparator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)lowerSeparator {
    return objc_getAssociatedObject(self, kLowerSeparatorAssociatedKey);
}

- (void)setLowerSeparator:(UIView *)lowerSeparator {
    return objc_setAssociatedObject(self, kLowerSeparatorAssociatedKey, lowerSeparator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)addUpperSeparatorWithColor:(UIColor *)color insets:(UIEdgeInsets)insets {
    if (!self.upperSeparator) {
        self.upperSeparator = [[UIView alloc] init];
        [self addSubview:self.upperSeparator];
    }
    
    {
        self.upperSeparator.backgroundColor = color;
        [self.upperSeparator mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(insets.left);
            make.right.equalTo(self).offset(-insets.right);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self.upperSeparator;
}

- (UIView *)addLowerSeparatorWithColor:(UIColor *)color insets:(UIEdgeInsets)insets {
    if (!self.lowerSeparator) {
        self.lowerSeparator = [[UIView alloc] init];
        [self addSubview:self.lowerSeparator];
    }
    
    {
        self.lowerSeparator.backgroundColor = color;
        [self.lowerSeparator mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-0.5);
            make.left.equalTo(self).offset(insets.left);
            make.right.equalTo(self).offset(-insets.right);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    return self.lowerSeparator;
}
@end

@interface UITableView ()
//@property (nonatomic,retain) id<AspectToken> aspectToken;
@end

@implementation UITableView (Separator)

//- (id<AspectToken>)aspectToken {
//    return objc_getAssociatedObject(self, kAspectTokenAssociatedKey);
//}
//
//- (void)setAspectToken:(id<AspectToken>)aspectToken {
//    objc_setAssociatedObject(self, kAspectTokenAssociatedKey, aspectToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (BOOL)hasRowSeparator {
    NSNumber *value = objc_getAssociatedObject(self, kHasRowSeparatorAssociatedKey);
    return value.boolValue;
}

- (void)setHasRowSeparator:(BOOL)hasRowSeparator {
    objc_setAssociatedObject(self, kHasRowSeparatorAssociatedKey, @(hasRowSeparator), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hasSectionBorder {
    NSNumber *value = objc_getAssociatedObject(self, kHasSectionBorderAssociatedKey);
    return value.boolValue;
}

- (void)setHasSectionBorder:(BOOL)hasSectionBorder {
    objc_setAssociatedObject(self, kHasSectionBorderAssociatedKey, @(hasSectionBorder), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)load {
    [self aspect_hookSelector:@selector(setDelegate:)
                  withOptions:AspectPositionAfter
                   usingBlock:^(id<AspectInfo> aspectInfo, id<UITableViewDelegate> delegate)
    {
        UITableView *thisTableView = [aspectInfo instance];
        if (![delegate conformsToProtocol:@protocol(UITableViewSeparatorDelegate) ]) {
//            [thisTableView.aspectToken remove];
            return ;
        }

        // Disable the separatorStyle property setting, the value is always UITableViewCellSeparatorStyleNone
        thisTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [thisTableView aspect_hookSelector:@selector(setSeparatorStyle:) withOptions:AspectPositionInstead usingBlock:^{} error:nil];
        
        void (^AddSeparatorWithDataSource)(id) = ^(id dataSource) {
            if ([dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
                [dataSource aspect_hookSelector:@selector(tableView:cellForRowAtIndexPath:)
                                                                  withOptions:AspectPositionInstead
                                                                   usingBlock:^(id<AspectInfo> dsAspectInfo,
                                                                             UITableView *tableView,
                                                                             NSIndexPath *indexPath)
                                            {
                                                void *retValue;
                                                [[dsAspectInfo originalInvocation] invoke];
                                                [[dsAspectInfo originalInvocation] getReturnValue:&retValue];
                                                UITableViewCell *cell = (__bridge UITableViewCell *)retValue;
                                                
                                                id<UITableViewSeparatorDelegate> separatorDelegate = (id<UITableViewSeparatorDelegate>)tableView.delegate;
                                                NSUInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
                                                if (([separatorDelegate respondsToSelector:@selector(tableView:hasBorderInSection:)]
                                                    && [separatorDelegate tableView:tableView hasBorderInSection:indexPath.section])
                                                    || tableView.hasSectionBorder)
                                                {
                                                    if (indexPath.row == 0) {
                                                        [cell addUpperSeparatorWithColor:tableView.separatorColor insets:UIEdgeInsetsZero];
                                                    }
                                                    if (indexPath.row == numberOfRows-1) {
                                                        [cell addLowerSeparatorWithColor:tableView.separatorColor insets:UIEdgeInsetsZero];
                                                    }
                                                }
                                                
                                                if (indexPath.row != numberOfRows-1) {
                                                    if (([separatorDelegate respondsToSelector:@selector(tableView:hasSeparatorBetweenIndexPath:andIndexPath:)]
                                                        && [separatorDelegate tableView:tableView
                                                           hasSeparatorBetweenIndexPath:indexPath
                                                                           andIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]])
                                                        || tableView.hasRowSeparator)
                                                    {
                                                        [cell addLowerSeparatorWithColor:tableView.separatorColor insets:tableView.separatorInset];
                                                    }
                                                }
                                            } error:nil];
            }
        };
        
        if (!thisTableView.dataSource) {
            [thisTableView aspect_hookSelector:@selector(setDataSource:)
                                  withOptions:AspectPositionAfter
                                   usingBlock:^(id<AspectInfo> dsAspectInfo, id<UITableViewDataSource> dataSource)
            {
                if (dataSource) {
                    AddSeparatorWithDataSource(dataSource);
                }
            } error:nil];
        } else {
            AddSeparatorWithDataSource(thisTableView.dataSource);
        }
    } error:nil];
}
@end
