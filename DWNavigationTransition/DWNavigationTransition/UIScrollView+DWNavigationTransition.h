//
//  UIScrollView+DWNavigationTransition.h
//  DWNavigationTransition
//
//  Created by Wicky on 2019/7/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (DWNavigationTransition)

#ifdef __IPHONE_11_0
@property (nonatomic, assign) BOOL dw_shouldRestoreContentInsetAdjustmentBehavior NS_AVAILABLE_IOS(11_0);
@property (nonatomic, assign) UIScrollViewContentInsetAdjustmentBehavior dw_storedContentInsetAdjustmentBehavior NS_AVAILABLE_IOS(11_0);
#endif

@end

NS_ASSUME_NONNULL_END
