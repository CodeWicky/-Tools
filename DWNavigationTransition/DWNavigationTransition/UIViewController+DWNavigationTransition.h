//
//  UIViewController+DWNavigationTransition.h
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (DWNavigationTransition)

@property (nonatomic ,assign) BOOL dw_userNavigationTransition;

@property (nonatomic ,strong) UINavigationBar * dw_transitionBar;

@property (nonatomic ,strong) UINavigationBar * dw_statusStoreBar;

-(void)dw_addTransitionBarIfNeeded;

@end

NS_ASSUME_NONNULL_END
