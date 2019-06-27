//
//  UINavigationBar+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import "UINavigationBar+DWNavigationTransition.h"

@implementation UINavigationBar (DWNavigationTransition)

-(void)copyFromBar:(UINavigationBar *)bar {
    self.barTintColor = bar.barTintColor;
    self.shadowImage = bar.shadowImage;
    self.barStyle = bar.barStyle;
    self.translucent = bar.translucent;
    [self setBackgroundImage:[bar backgroundImageForBarMetrics:(UIBarMetricsDefault)] forBarMetrics:(UIBarMetricsDefault)];
    self.hidden = bar.isHidden;
}

@end
