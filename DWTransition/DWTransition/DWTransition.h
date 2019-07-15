//
//  DWTransition.h
//  DWTransition
//
//  Created by Wicky on 2019/5/20.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 控制器转场类
 
 用于快速自定制 UITabBarController / UINavigationController / UIViewController 的转场动画。
 
 version 1.0.0
 提供基础转场动画及定制接口。
 */

typedef NS_OPTIONS(NSUInteger, DWTransitionType) {
    ///Describe default transition type which means that push and from right.
    DWTransitionDefaultType = 0,
    
    ///Describe current transition is either push、pop、present or dismiss.
    DWTransitionPushType = 1 << 0,
    DWTransitionPopType = 1 << 1,
    DWTransitionPresentType = 1 << 2,
    DWTransitionDismissType = 1 << 3,
    DWTransitionTransparentPushType = 1 << 4,
    DWTransitionTransparentPopType = 1 << 5,
    
    ///Describe current transition's animation type
    DWTransitionAnimationMoveInFromLeftType = 1 << 6,
    DWTransitionAnimationMoveInFromRightType = 1 << 7,
    DWTransitionAnimationMoveInFromTopType = 1 << 8,
    DWTransitionAnimationMoveInFromBottomType = 1 << 9,
    DWTransitionAnimationZoomInType = 1 << 10,
    DWTransitionAnimationFadeInType = 1 << 11,
    DWTransitionAnimationCustomType = 1 << 12,
    DWTransitionAnimationNoneType = 1 << 13,
    
    ///Describe push or animaiton type mask.
    DWTransitionTypeMask = 0x003f,
    DWTransitionAnimationTypeMask = 0x3fc0,
};

///Follow DWTransitionProtocol so that viewcontroller can manager animationType itself.
@protocol DWTransitionProtocol <NSObject>

///Describe the animationType for push or present a new viewController.
@property (nonatomic ,assign) DWTransitionType dw_pushAnimationType;

///Describe the animationType for pop or dismiss an old viewController.
@property (nonatomic ,assign) DWTransitionType dw_popAnimationType;

///Indicate that should use this animationType preferentially if you operate several viewControllers at the same time.
@property (nonatomic ,assign) BOOL dw_animationFlag;

@end

@class DWTransition;
typedef void(^DWCustomTransitionHandler)(DWTransition * transition,id <UIViewControllerContextTransitioning> transitionContext);

///DWTransition can provide an easy to customsize push/present transition.
@interface DWTransition : NSObject<UIViewControllerAnimatedTransitioning>

///Initialize with DWTransitionAnimationCustomType and provide customTransition in order to customsize the transition as you want.
@property (nonatomic ,copy) DWCustomTransitionHandler customTransition;

///Transition duration controls how long the transition will take.Default by 0.4.
@property (nonatomic ,assign) CGFloat transitionDuration;

+(instancetype)transitionWithType:(DWTransitionType)type;

+(instancetype)transitionWithType:(DWTransitionType)type customTransition:(DWCustomTransitionHandler)customTransition;

+(instancetype)transitionWithType:(DWTransitionType)type duration:(CGFloat)duration customTransition:(DWCustomTransitionHandler)customTransition;

@end


