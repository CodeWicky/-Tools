//
//  DWTransition.h
//  DWTransition
//
//  Created by Wicky on 2019/5/20.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, DWTransitionType) {
    ///Describe default transition type.
    DWTransitionDefaultType = 0,
    
    ///Describe current transition is either push or pop.
    DWTransitionPushType = 1 << 0,
    DWTransitionPopType = 1 << 1,
    
    ///Describe current transition's animation type
    DWTransitionPushAnimationMoveInFromLeftType = 1 << 2,
    DWTransitionPushAnimationMoveInFromRightType = 1 << 3,
    DWTransitionPushAnimationMoveInFromTopType = 1 << 4,
    DWTransitionPushAnimationMoveInFromBottomType = 1 << 5,
    DWTransitionPushAnimationZoomInType = 1 << 6,
    DWTransitionPushAniamtionFadeInType = 1 << 7,
    DWTransitionPushAnimationCustomType = 1 << 8,
    DWTransitionPushAnimationNoneType = 1 << 9,
    
    ///Describe push or animaiton type mask.
    DWTransitionPushTypeMask = 0x03,
    DWTransitionAnimationTypeMask = 0x3fc,
};

///Follow DWTransitionProtocol so that viewcontroller can manager animationType itself.
@protocol DWTransitionProtocol <NSObject>

@property (nonatomic ,assign) DWTransitionType animationType;

@end

@class DWTransition;
typedef void(^DWCustomTransitionHandler)(DWTransition * transition,id <UIViewControllerContextTransitioning> transitionContext);

///DWTransition can provide an easy to customsize push/present transition.
@interface DWTransition : NSObject<UIViewControllerAnimatedTransitioning>

///Initialize with DWTransitionPushAnimationCustomType and provide customTransition in order to customsize the transition as you want.
@property (nonatomic ,copy) DWCustomTransitionHandler customTransition;

///Transition duration controls how long the transition will take.Default by 0.4.
@property (nonatomic ,assign) CGFloat transitionDuration;

+(instancetype)transitionWithType:(DWTransitionType)type;

+(instancetype)transitionWithType:(DWTransitionType)type customTransition:(DWCustomTransitionHandler)customTransition;

+(instancetype)transitionWithType:(DWTransitionType)type duration:(CGFloat)duration customTransition:(DWCustomTransitionHandler)customTransition;

@end


