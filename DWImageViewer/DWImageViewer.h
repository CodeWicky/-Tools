//
//  DWImageViewer.h
//  GomeLoanClient
//
//  Created by Wicky on 2018/1/21.
//  Copyright © 2018年 GMJK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWImageViewer : UIWindow

+(void)viewImageView:(UIImageView *)view;

+(void)viewImageView:(UIImageView *)view uploadHandler:(dispatch_block_t)handler;

@end
