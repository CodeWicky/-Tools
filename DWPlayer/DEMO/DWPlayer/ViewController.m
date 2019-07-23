//
//  ViewController.m
//  DWPlayer
//
//  Created by Wicky on 2019/7/23.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "ViewController.h"
#import <DWPlayer.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DWPlayerViewController * player = [DWPlayerViewController new];
    player.view.backgroundColor = [UIColor blackColor];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"video4" ofType:@"mp4"];
    NSURL * url = [NSURL fileURLWithPath:filePath];
    [player configVideoWithURL:url];
    [self presentViewController:player animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [player play];
        });
    }];
}


@end
