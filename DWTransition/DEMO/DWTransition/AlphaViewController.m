//
//  AlphaViewController.m
//  DWTransition
//
//  Created by Wicky on 2019/7/23.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "AlphaViewController.h"

@interface AlphaViewController ()

@end

@implementation AlphaViewController
@synthesize dw_pushAnimationType;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.navigationController.viewControllers.count < 5) {
        [self.navigationController pushViewController:[AlphaViewController new] animated:YES];
    } else {
        UIViewController * vc = self.navigationController.viewControllers[2];
        [self.navigationController popToViewController:vc animated:YES];
    }
}

-(instancetype)init {
    if (self = [super init]) {
        self.dw_pushAnimationType = DWTransitionTransparentPushType;
    }
    return self;
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
