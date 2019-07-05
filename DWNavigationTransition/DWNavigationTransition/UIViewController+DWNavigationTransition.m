//
//  UIViewController+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import "UIViewController+DWNavigationTransition.h"
#import "UINavigationController+DWNavigationTransition.h"
#import "UINavigationBar+DWNavigationTransition.h"
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
        
    }
}

-(void)dw_viewWillLayoutSubviews {
    if (self.dw_userNavigationTransition) {
        UIViewController * toVC = [self.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        if (toVC && [self isEqual:toVC] && [self isEqual:self.navigationController.viewControllers.lastObject]) {
            if (self.dw_isPushTransition) {
                [self dw_addTransitionBarIfNeeded];
                self.dw_isPushTransition = NO;
            } else if (self.dw_isPopTransition) {
                [self dw_restoreTransitionBarIfNeeded];
                [self dw_configTransitionBarHiddenIfNeeded:NO];
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
    [self dw_adjustScrollViewContentOffsetIfNeeded];
    [self.dw_transitionBar copyFromBar:self.navigationController.navigationBar];
    if (!self.navigationController.navigationBar.isHidden) {
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
    [self.dw_transitionBar copyFromBar:self.dw_statusStoreBar];
    if (!self.navigationController.navigationBar.isHidden) {
        [self dw_resizeTransitionBarFrame];
        [self.view addSubview:self.dw_transitionBar];
    } else {
        [self.dw_transitionBar removeFromSuperview];
    }
}

-(void)dw_removeTransitionBarIfNeeded {
    [self.dw_transitionBar removeFromSuperview];
}

-(void)dw_configTransitionBarHiddenIfNeeded:(BOOL)hidden {
    if (self.dw_transitionBar.superview) {
        self.dw_transitionBar.dw_backgroundView.hidden = hidden;
        self.dw_transitionBar.dw_isHiddenBackgroundViewForFakeBar = hidden;
    }
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
