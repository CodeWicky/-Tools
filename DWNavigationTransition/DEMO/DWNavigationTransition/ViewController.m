//
//  ViewController.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIViewController * red = [UIViewController new];
    red.view.backgroundColor = [UIColor redColor];
    [self.navigationController pushViewController:red animated:YES];
}


@end
