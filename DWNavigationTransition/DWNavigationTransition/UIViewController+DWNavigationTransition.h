//
//  UIViewController+DWNavigationTransition.h
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DWNavigationTransition)

@property (nonatomic ,assign) BOOL dw_useNavigationTransition;

@property (nonatomic ,assign) BOOL dw_inTransition;

@property (nonatomic ,strong) UINavigationBar * dw_transitionBar;

@property (nonatomic ,strong) UINavigationBar * dw_statusStoreBar;

@property (nonatomic ,strong) UIViewController * dw_transitioningViewController;

@property (nonatomic ,assign) BOOL dw_isPushTransition;

@property (nonatomic ,assign) BOOL dw_isPopTransition;

-(void)dw_addTransitionBarIfNeeded;

-(void)dw_removeTransitionBarIfNeeded;

-(void)dw_resizeTransitionBarFrame;

@end
