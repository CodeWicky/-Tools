//
//  NavViewController.m
//  DWTransition
//
//  Created by Wicky on 2019/7/13.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "NavViewController.h"
#import "DWTransition.h"

@interface NavViewController ()<UINavigationControllerDelegate>

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        return [DWTransition transitionWithType:(DWTransitionPushType)];
    } else {
        return [DWTransition transitionWithType:(DWTransitionPopType)];
    }
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
