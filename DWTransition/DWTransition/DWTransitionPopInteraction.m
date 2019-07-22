//
//  DWTransitionPopInteraction.m
//  DWTransition
//
//  Created by Wicky on 2019/7/22.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWTransitionPopInteraction.h"

@interface DWTransitionPopInteraction ()<UIGestureRecognizerDelegate>

@end

@implementation DWTransitionPopInteraction

#pragma mark --- interface method ---
+(instancetype)interactionWithNavigationController:(UINavigationController *)navi {
    return [[self alloc] initWithNavigationController:navi];
}

#pragma mark --- tool method ---
-(instancetype)initWithNavigationController:(UINavigationController *)navi {
    if (self = [super init]) {
        self.navigationController = navi;
        UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] init];
        popRecognizer.delegate = self;
        popRecognizer.maximumNumberOfTouches = 1;
        [popRecognizer addTarget:self action:@selector(popGestureAction:)];
        popRecognizer.enabled = navi.interactivePopGestureRecognizer.enabled;
        [navi.interactivePopGestureRecognizer.view addGestureRecognizer:popRecognizer];
        self.popInteractionGestureRecognizer = popRecognizer;
        navi.interactivePopGestureRecognizer.enabled = NO;
    }
    return self;
}

-(void)popGestureAction:(UIPanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:recognizer.view].x / recognizer.view.bounds.size.width;
    progress = MIN(1.0, MAX(0.0, progress));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self updateInteractiveTransition:progress];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (progress > 0.5) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.viewControllers.count != 1 && ![[self.navigationController valueForKey:@"_isTransitioning"] boolValue];
}



@end
