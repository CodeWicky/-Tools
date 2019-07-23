//
//  ViewController.m
//  DWTransition
//
//  Created by Wicky on 2019/7/13.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "AlphaViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(arc4random() % 256) / 255.0 green:(arc4random() % 256) / 255.0 blue:(arc4random() % 256) / 255.0 alpha:1];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:[AlphaViewController new] animated:YES];
}

@end
