//
//  ViewController.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/24.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIViewController * red = [[UIViewController alloc] init];
    red.view.backgroundColor = [UIColor redColor];
    [self.navigationController pushViewController:red animated:YES];
}


@end
