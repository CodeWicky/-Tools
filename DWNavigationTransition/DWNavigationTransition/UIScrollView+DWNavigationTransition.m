//
//  UIScrollView+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/7/6.
//

#import "UIScrollView+DWNavigationTransition.h"
#import "DWTransitionFunction.h"

@implementation UIScrollView (DWNavigationTransition)

-(void)setDw_shouldRestoreContentInsetAdjustmentBehavior:(BOOL)dw_shouldRestoreContentInsetAdjustmentBehavior {
    DWQuickSetAssociatedValue(@selector(dw_shouldRestoreContentInsetAdjustmentBehavior), @(dw_shouldRestoreContentInsetAdjustmentBehavior));
}

-(BOOL)dw_shouldRestoreContentInsetAdjustmentBehavior {
    return [DWQuickGetAssociatedValue() boolValue];
}

-(void)setDw_storedContentInsetAdjustmentBehavior:(UIScrollViewContentInsetAdjustmentBehavior)dw_storedContentInsetAdjustmentBehavior {
    DWQuickSetAssociatedValue(@selector(dw_storedContentInsetAdjustmentBehavior), @(dw_storedContentInsetAdjustmentBehavior));
}

-(UIScrollViewContentInsetAdjustmentBehavior)dw_storedContentInsetAdjustmentBehavior {
    return [DWQuickGetAssociatedValue() boolValue];
}

@end
