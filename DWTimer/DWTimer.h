//
//  DWTimer.h
//  GCDTimer
//
//  Created by Wicky on 16/9/23.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWTimer : NSObject
@property (nonatomic ,copy)void(^cancelHandler)();
+(instancetype)dw_TimerWithTimeInterval:(NSTimeInterval)timeInterval
                                  delay:(NSTimeInterval)delay
                              mainQueue:(BOOL)mainQueue
                                handler:(void(^)())handler;
-(void)resume;
-(void)suspend;
-(void)cancel;
-(void)invalid;
@end
