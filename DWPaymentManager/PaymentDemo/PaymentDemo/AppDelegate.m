//
//  AppDelegate.m
//  PaymentDemo
//
//  Created by Wicky on 2017/8/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "AppDelegate.h"
#import "DWPaymentManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    DWPaymentConfig * wxConfig = [DWPaymentConfig new];
    wxConfig.payType = DWPaymentTypeWeiXin;
    wxConfig.AppID = @"wx7e1a39693cb1a1f1";
    
    [DWPaymentManager registPaymentManagerWithConfigs:@[wxConfig]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [DWPaymentManager paymentCallBackDefaultHandlerWithUrl:url otherHanlder:^BOOL{
        return NO;
    }];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
