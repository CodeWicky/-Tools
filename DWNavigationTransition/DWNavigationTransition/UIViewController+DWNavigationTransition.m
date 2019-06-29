//
//  UIViewController+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import "UIViewController+DWNavigationTransition.h"
#import "UINavigationBar+DWNavigationTransition.h"
#import "DWTransitionFunction.h"

@implementation UIViewController (DWNavigationTransition)
@dynamic dw_userNavigationTransition,dw_transitionBar,dw_statusStoreBar;

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

#pragma mark --- tool method ---
-(UIScrollView *)scrollContainer {
    UIScrollView * scroll = DWQuickGetAssociatedValue();
    if (!scroll && ![DWGetAssociatedValue(self, "scrollViewHandled") boolValue]) {
        DWSetAssignAssociatedValue(self, "scrollViewHandled", @(YES));
        if ([self.view isKindOfClass:[UIScrollView class]]) {
            scroll = (UIScrollView *)self.view;
            DWQuickSetStrongAssociatedValue(_cmd, scroll);
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
-(BOOL)dw_userNavigationTransition {
    NSNumber * use = DWQuickGetAssociatedValue();
    if (!use) {
        use = [NSNumber numberWithBool:YES];
        DWQuickSetStrongAssociatedValue(_cmd, use);
    }
    return [use boolValue];
}

-(void)setDw_userNavigationTransition:(BOOL)dw_userNavigationTransition {
    DWQuickSetAssignAssociatedValue(@selector(dw_userNavigationTransition), [NSNumber numberWithBool:dw_userNavigationTransition]);
}

-(UINavigationBar *)dw_transitionBar {
    UINavigationBar * bar = DWQuickGetAssociatedValue();
    if (!bar) {
        bar = [[UINavigationBar alloc] init];
        DWQuickSetStrongAssociatedValue(_cmd, bar);
    }
    return bar;
}

-(void)setDw_transitionBar:(UINavigationBar *)dw_transitionBar {
    DWQuickSetStrongAssociatedValue(@selector(dw_transitionBar), dw_transitionBar);
}

-(UINavigationBar *)dw_statusStoreBar {
    UINavigationBar * bar = DWQuickGetAssociatedValue();
    if (!bar) {
        bar = [[UINavigationBar alloc] init];
        DWQuickSetStrongAssociatedValue(_cmd, bar);
    }
    return bar;
}

-(void)setDw_statusStoreBar:(UINavigationBar *)dw_statusStoreBar {
    DWQuickSetStrongAssociatedValue(@selector(dw_transitionBar), dw_statusStoreBar);
}

@end
