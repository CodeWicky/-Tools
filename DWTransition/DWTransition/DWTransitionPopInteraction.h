//
//  DWTransitionPopInteraction.h
//  DWTransition
//
//  Created by Wicky on 2019/7/22.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 控制器转场交互类
 
 用于配合DWTransition使用时为侧滑返回提供默认实现
 
 version 1.0.0
 提供侧滑返回的默认实现
 */

@interface DWTransitionPopInteraction : UIPercentDrivenInteractiveTransition

///The navigationController for current popInteraction.
@property (nonatomic ,weak) UINavigationController * navigationController;

///To support slide on edge when using DWTransition,custom the recognizer of popInteraction.
@property (nonatomic ,strong) UIPanGestureRecognizer * popInteractionGestureRecognizer;

+(instancetype)interactionWithNavigationController:(UINavigationController *)navi;

@end
