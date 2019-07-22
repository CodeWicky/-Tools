//
//  NavViewController.m
//  DWTransition
//
//  Created by Wicky on 2019/7/13.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "NavViewController.h"
#import "DWTransition.h"
#import "DWTransitionPopInteraction.h"
@interface NavViewController ()<UINavigationControllerDelegate>

@property (nonatomic ,strong) DWTransitionPopInteraction * interaction;

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.interaction = [DWTransitionPopInteraction interactionWithNavigationController:self];
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        return [DWTransition transitionWithType:(DWTransitionPushType)];
    } else {
        return [DWTransition transitionWithType:(DWTransitionPopType | DWTransitionAnimationMoveInFromBottomType)];
    }
}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    ///配合DWTransition使用
    if ([animationController isKindOfClass:[DWTransition class]]) {
        ///当本次返回是由侧滑返回触发时才进行定制
        if (self.interaction.popInteractionGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            DWTransition * trans = (DWTransition *)animationController;
            DWTransitionType type = trans.transitionType & DWTransitionTypeMask;
            ///当当前动画过程是消失是才触发
            if (type == DWTransitionPopType || type == DWTransitionTransparentPopType || type == DWTransitionDismissType) {
                return self.interaction;
            }
            return nil;
        }
        return nil;
    }
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
