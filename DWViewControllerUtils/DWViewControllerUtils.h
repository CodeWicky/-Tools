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
 
 version 1.0.1
 提供导航栏透明度自动自动设置方法
 */

#import <UIKit/UIKit.h>

@interface UINavigationController (DWNavigationUtils)<UINavigationBarDelegate>

///是否使用透明导航栏自动处理
@property (nonatomic ,assign) BOOL dw_AutomaticallyHandleNavBarAlpha;


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


/**
 改变当前navgationBar透明度

 @param alpha 目标透明度
 @param animated 是否动画展示
 @param duration 若需动画展示的动画时间，指定值需大于0，否则使用系统默认动画时间
 */
-(void)handleNavigationBarAlphaTo:(CGFloat)alpha animated:(BOOL)animated animationDuration:(CGFloat)duration;

@end

@interface UIViewController (DWNavigationUtils)

///当前控制器对应导航栏透明度
/**
 注：设置本属性并不会立即更新当前导航栏透明度，当导航控制器push或pop时导航栏会改变至此透明度。
 若想立即改变当前navigationBar透明度，请调用UINavigationController中提供的
 -handleNavigationBarAlphaTo:animated:animationDuration:
 */
@property (nonatomic ,assign) CGFloat navigationBarAlpha;

/**
 模态返回值条件控制器

 @param animated 是否需要动画
 @param completion 移除结束后回调
 
 配合-pushViewController:animated:conditionPresentVC:conditionBlock:可按需显示控制器
 */
-(void)dismissToConditionVCToPushAnimated:(BOOL)animated completion:(void(^)())completion;

@end
