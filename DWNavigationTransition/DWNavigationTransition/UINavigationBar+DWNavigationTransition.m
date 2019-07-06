//
//  UINavigationBar+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import "UINavigationBar+DWNavigationTransition.h"
#import "DWTransitionFunction.h"

@implementation UINavigationBar (DWNavigationTransition)

#ifdef __IPHONE_11_0
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DWQuickSwizzleMethod(layoutSubviews, dw_layoutSubviews);
    });
}
#endif

-(void)dw_layoutSubviews {
    [self dw_layoutSubviews];
    CGRect frame = self.dw_backgroundView.frame;
    frame.size.height = self.frame.size.height + fabs(frame.origin.y);
    self.dw_backgroundView.frame = frame;
}

-(void)copyFromBar:(UINavigationBar *)bar {
    self.barTintColor = bar.barTintColor;
    self.shadowImage = bar.shadowImage;
    self.barStyle = bar.barStyle;
    self.translucent = bar.translucent;
    [self setBackgroundImage:[bar backgroundImageForBarMetrics:(UIBarMetricsDefault)] forBarMetrics:(UIBarMetricsDefault)];
}

#pragma mark --- setter/getter ---
-(UIView *)dw_backgroundView {
    UIView * view = DWQuickGetAssociatedValue();
    if (!view) {
        view = [self valueForKey:@"_backgroundView"];
        DWQuickSetAssociatedValue(_cmd, view);
    }
    return view;
}

-(void)setDw_isFakeBar:(BOOL)dw_isFakeBar {
    DWQuickSetAssociatedValue(@selector(dw_isFakeBar), @(dw_isFakeBar));
}

-(BOOL)dw_isFakeBar {
    return [DWQuickGetAssociatedValue() boolValue];
}

@end
