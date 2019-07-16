//
//  UINavigationBar+DWNavigationTransition.h
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (DWNavigationTransition)

@property (nonatomic ,strong ,readonly) UIView * dw_backgroundView;

@property (nonatomic ,assign) BOOL dw_isFakeBar;

-(void)copyFromBar:(UINavigationBar *)bar;

@end
