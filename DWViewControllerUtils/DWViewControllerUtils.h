//
//  UINavigationController+DWNavigationUtils.h
//  DWNavigationUtils
//
//  Created by Wicky on 2017/2/20.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWViewControllerUtils
 控制器扩展工具类
 
 version 1.0.0
 提供条件跳转api
 多层级dismiss闪烁问题需处理
 */

#import <UIKit/UIKit.h>

@interface UINavigationController (DWNavigationUtils)


/**
 根据条件进行控制器推进

 @param viewController 将要推进的控制器
 @param animated 是否需要动画
 @param condition 推进条件，返回yes则正常推进，否则调用条件回调handler
 @param handler 条件回调
 */
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated conditionBlock:(BOOL(^)())condition conditionHandler:(void(^)())handler;


/**
 根据条件进行控制器推进

 @param viewController 将要推进的控制器
 @param animated 是否需要动画
 @param presentVC 不满足突进条件将要推进的控制器
 @param condition 推进条件，返回yes正常推进，否则推进presentVC
 
 若推进presentVC后可调用-dismissToConditionVCToPushAnimated:completion:直接回到viewController
 */
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated conditionPresentVC:(UIViewController *)presentVC conditionBlock:(BOOL (^)())condition;

@end

@interface UIViewController (DWNavigationUtils)


/**
 移除模态界面并按需显示正确控制器

 @param animated 是否需要动画
 @param completion 移除结束后回调
 
 配合-pushViewController:animated:conditionPresentVC:conditionBlock:可按需显示控制器
 */
-(void)dismissToConditionVCToPushAnimated:(BOOL)animated completion:(void(^)())completion;

@end
