//
//  ViewController.m
//  DWDispatcher
//
//  Created by Wicky on 2019/9/26.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWDispatcher.h"

@interface ViewController ()

@property (nonatomic ,strong) DWDispatcher * dispatcher;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static int i = 0;
    [self.dispatcher dispatchObject:@(i)];
    i++;
}

#pragma mark --- setter/getter ---
-(DWDispatcher *)dispatcher {
    if (!_dispatcher) {
        _dispatcher = [DWDispatcher dispatcherWithTimeInterval:1 handler:^(NSArray * _Nonnull items) {
            NSLog(@"%@",items);
        }];
    }
    return _dispatcher;
}

@end
