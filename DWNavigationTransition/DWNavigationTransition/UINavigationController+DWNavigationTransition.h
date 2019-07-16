//
//  UINavigationController+DWNavigationTransition.h
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/24.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (DWNavigationTransition)

@property (nonatomic ,assign ,readonly) BOOL dw_useNavigationTransition;

@property (nonatomic ,assign) BOOL dw_backgroundViewHidden;

@end
