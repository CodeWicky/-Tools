//
//  UIViewController+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import "UIViewController+DWNavigationTransition.h"
#import "UINavigationController+DWNavigationTransition.h"
#import "UINavigationBar+DWNavigationTransition.h"
#import "UIScrollView+DWNavigationTransition.h"
#import "DWTransitionFunction.h"

@implementation UIViewController (DWNavigationTransition)
@dynamic dw_userNavigationTransition,dw_transitionBar,dw_statusStoreBar,dw_transitioningViewController;

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DWQuickSwizzleMethod(viewWillAppear:, dw_viewWillAppear:);
        DWQuickSwizzleMethod(viewWillLayoutSubviews, dw_viewWillLayoutSubviews);
        DWQuickSwizzleMethod(viewDidAppear:, dw_viewDidAppear:);
    });
}

-(void)dw_viewWillAppear:(BOOL)animated {
    [self dw_viewWillAppear:animated];
    if (self.dw_userNavigationTransition) {
        UIViewController *toVC = [self.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        if (toVC && [self isEqual:toVC] && [self isEqual:self.navigationController.viewControllers.lastObject]) {
            ///调整contentInset，方便layout时计算
            [self dw_adjustScrollViewContentInsetAdjustmentBehavior];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.navigationController.isNavigationBarHidden) {
                    ///提交到下一次runloop中并恢复状态
                    [self dw_restoreScrollViewContentInsetAdjustmentBehaviorIfNeeded];
                }
            });
        }
    }
}

-(void)dw_viewWillLayoutSubviews {
    if (self.dw_userNavigationTransition) {
        UIViewController * toVC = [self.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        if (toVC && [self isEqual:toVC] && [self isEqual:self.navigationController.viewControllers.lastObject]) {
            if (self.dw_isPushTransition) {
                ///Push时添加新的Bar
                [self dw_addTransitionBarIfNeeded];
                self.dw_isPushTransition = NO;
            } else if (self.dw_isPopTransition) {
                ///Pop时应该恢复之前记录的Bar
                [self dw_restoreTransitionBarIfNeeded];
                self.dw_isPopTransition = NO;
            }
            if (self.dw_transitionBar.superview) {
                [self.view bringSubviewToFront:self.dw_transitionBar];
            }
        }
    }
    [self dw_viewWillLayoutSubviews];
}

-(void)dw_viewDidAppear:(BOOL)animated {
    if (self.dw_userNavigationTransition) {
        [self dw_restoreScrollViewContentInsetAdjustmentBehaviorIfNeeded];
        [self dw_removeTransitionBarIfNeeded];
        if (self.dw_transitioningViewController) {
            self.navigationController.dw_backgroundViewHidden = NO;
            [self.dw_transitioningViewController dw_removeTransitionBarIfNeeded];
        }
    }
    [self dw_viewDidAppear:animated];
}

#pragma mark --- interface method ---
-(void)dw_addTransitionBarIfNeeded {
    if (!self.isViewLoaded || !self.view.window || !self.dw_userNavigationTransition || !self.navigationController.navigationBar || self.navigationController.navigationBar.isHidden) {
        [self.dw_transitionBar removeFromSuperview];
        return;
    }
    ///防止ContentOffset为负，先调整至正常范围内
    [self dw_adjustScrollViewContentOffsetIfNeeded];
    [self.dw_transitionBar copyFromBar:self.navigationController.navigationBar];
    if (!self.navigationController.isNavigationBarHidden && !self.navigationController.navigationBar.isHidden) {
        ///调整Bar的尺寸
        [self dw_resizeTransitionBarFrame];
        [self.view addSubview:self.dw_transitionBar];
    } else {
        [self.dw_transitionBar removeFromSuperview];
    }
}

-(void)dw_restoreTransitionBarIfNeeded {
    if (!self.isViewLoaded || !self.view.window || !self.dw_userNavigationTransition || !self.navigationController.navigationBar || self.navigationController.navigationBar.isHidden) {
        [self.dw_transitionBar removeFromSuperview];
        return;
    }
    [self dw_adjustScrollViewContentOffsetIfNeeded];
    ///从记录中恢复状态
    [self.dw_transitionBar copyFromBar:self.dw_statusStoreBar];
    if (!self.navigationController.isNavigationBarHidden && !self.navigationController.navigationBar.isHidden) {
        [self dw_resizeTransitionBarFrame];
        ///实际导航也要恢复状态
        [self.navigationController.navigationBar copyFromBar:self.dw_statusStoreBar];
        [self.view addSubview:self.dw_transitionBar];
    } else {
        [self.dw_transitionBar removeFromSuperview];
    }
}

-(void)dw_removeTransitionBarIfNeeded {
    [self.dw_transitionBar removeFromSuperview];
}

#pragma mark --- tool method ---
-(UIScrollView *)scrollContainer {
    UIScrollView * scroll = DWQuickGetAssociatedValue();
    if (!scroll && ![DWGetAssociatedValue(self, "scrollViewHandled") boolValue]) {
        DWSetAssociatedValue(self, "scrollViewHandled", @(YES));
        if ([self.view isKindOfClass:[UIScrollView class]]) {
            scroll = (UIScrollView *)self.view;
            DWQuickSetAssociatedValue(_cmd, scroll);
        }
    }
    return scroll;
}

-(void)dw_adjustScrollViewContentOffsetIfNeeded {
    UIScrollView * scrollContainer = [self scrollContainer];
    if (scrollContainer) {
        UIEdgeInsets contentInset;
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            contentInset = scrollContainer.adjustedContentInset;
        } else {
            contentInset = scrollContainer.contentInset;
        }
#else
        contentInset = scrollView.contentInset;
#endif
        const CGFloat topContentOffsetY = -contentInset.top;
        const CGFloat bottomContentOffsetY = scrollContainer.contentSize.height - (CGRectGetHeight(scrollContainer.bounds) - contentInset.bottom);
        
        CGPoint adjustedContentOffset = scrollContainer.contentOffset;
        if (adjustedContentOffset.y > bottomContentOffsetY) {
            adjustedContentOffset.y = bottomContentOffsetY;
        }
        if (adjustedContentOffset.y < topContentOffsetY) {
            adjustedContentOffset.y = topContentOffsetY;
        }
        [scrollContainer setContentOffset:adjustedContentOffset animated:NO];
    }
}

- (void)dw_resizeTransitionBarFrame {
    if (!self.view.window) {
        return;
    }
    UIView *backgroundView = self.navigationController.navigationBar.dw_backgroundView;
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    self.dw_transitionBar.frame = rect;
}

- (void)dw_adjustScrollViewContentInsetAdjustmentBehavior {
#ifdef __IPHONE_11_0
    if (self.navigationController.navigationBar.translucent) {
        return;
    }
    if (@available(iOS 11.0, *)) {
        UIScrollView *scrollView = [self scrollContainer];
        if (scrollView) {
            UIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior = scrollView.contentInsetAdjustmentBehavior;
            if (contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
                scrollView.dw_storedContentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior;
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
                scrollView.dw_shouldRestoreContentInsetAdjustmentBehavior = YES;
            }
        }
    }
#endif
}

- (void)dw_restoreScrollViewContentInsetAdjustmentBehaviorIfNeeded {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        UIScrollView *scrollView = [self scrollContainer];
        if (scrollView) {
            if (scrollView.dw_shouldRestoreContentInsetAdjustmentBehavior) {
                scrollView.contentInsetAdjustmentBehavior = scrollView.dw_storedContentInsetAdjustmentBehavior;
                scrollView.dw_shouldRestoreContentInsetAdjustmentBehavior = NO;
            }
        }
    }
#endif
}


#pragma mark --- setter/getter ---
-(void)setDw_userNavigationTransition:(BOOL)dw_userNavigationTransition {
    if ([self isKindOfClass:[UINavigationController class]] || [self isKindOfClass:[UITabBarController class]]) {
        return ;
    }
    DWQuickSetAssociatedValue(@selector(dw_userNavigationTransition), @(dw_userNavigationTransition));
}

-(BOOL)dw_userNavigationTransition {
    if ([self isKindOfClass:[UINavigationController class]] || [self isKindOfClass:[UITabBarController class]]) {
        return NO;
    }
    NSNumber * use = DWQuickGetAssociatedValue();
    if (!use) {
        use = @(YES);
        DWQuickSetAssociatedValue(_cmd, use);
    }
    return [use boolValue];
}

-(void)setDw_transitionBar:(UINavigationBar *)dw_transitionBar {
    DWQuickSetAssociatedValue(@selector(dw_transitionBar), dw_transitionBar);
}

-(UINavigationBar *)dw_transitionBar {
    UINavigationBar * bar = DWQuickGetAssociatedValue();
    if (!bar) {
        bar = [[UINavigationBar alloc] init];
        bar.dw_isFakeBar = YES;
        DWQuickSetAssociatedValue(_cmd, bar);
    }
    return bar;
}

-(void)setDw_statusStoreBar:(UINavigationBar *)dw_statusStoreBar {
    DWQuickSetAssociatedValue(@selector(dw_transitionBar), dw_statusStoreBar);
}

-(UINavigationBar *)dw_statusStoreBar {
    UINavigationBar * bar = DWQuickGetAssociatedValue();
    if (!bar) {
        bar = [[UINavigationBar alloc] init];
        bar.dw_isFakeBar = YES;
        DWQuickSetAssociatedValue(_cmd, bar);
    }
    return bar;
}

-(void)setDw_transitioningViewController:(UIViewController *)dw_transitioningViewController {
    DWQuickSetAssociatedValue(@selector(dw_transitioningViewController), dw_transitioningViewController);
}

-(UIViewController *)dw_transitioningViewController {
    return DWQuickGetAssociatedValue();
}

-(void)setDw_isPushTransition:(BOOL)dw_isPushTransition {
    DWQuickSetAssociatedValue(@selector(dw_isPushTransition), @(dw_isPushTransition));
}

-(BOOL)dw_isPushTransition {
    return [DWQuickGetAssociatedValue() boolValue];
}

-(void)setDw_isPopTransition:(BOOL)dw_isPopTransition {
    DWQuickSetAssociatedValue(@selector(dw_isPopTransition), @(dw_isPopTransition));
}

-(BOOL)dw_isPopTransition {
    return [DWQuickGetAssociatedValue() boolValue];
}

@end
