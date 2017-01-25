//
//  DWTimer.m
//  GCDTimer
//
//  Created by Wicky on 16/9/23.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWTimer.h"

@interface DWTimer ()

@property (nonatomic ,copy)void(^handler)();

@property (nonatomic) dispatch_source_t timer;

@property (nonatomic ,assign) BOOL isResume;

@end

@implementation DWTimer
+(instancetype)dw_TimerWithTimeInterval:(NSTimeInterval)timeInterval
                                  delay:(NSTimeInterval)delay
                              mainQueue:(BOOL)mainQueue
                                handler:(void (^)())handler
{
    DWTimer * dwT = [[DWTimer alloc] init];
    dwT.handler = handler;
    dispatch_queue_t queue = mainQueue?dispatch_get_main_queue():dispatch_get_global_queue(0, 0);
    dwT.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(dwT.timer, dispatch_walltime(NULL, delay * NSEC_PER_SEC), timeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(dwT.timer, ^{
        if (handler) {
            handler();
        }
    });
    [dwT resume];
    return dwT;
}

-(void)resume
{
    if (!self.isResume) {
        self.isResume = YES;
        dispatch_resume(self.timer);
    }
}

-(void)suspend
{
    if (self.isResume) {
        self.isResume = NO;
        dispatch_suspend(self.timer);
    }
}

-(void)setCancelHandler:(void (^)())cancelHandler
{
    _cancelHandler = cancelHandler;
    dispatch_source_set_cancel_handler(self.timer, ^{
        cancelHandler();
    });
}

-(void)cancel
{
    if (self.isResume) {
        dispatch_source_cancel(self.timer);
    }
}

-(void)invalid
{
    [self resume];
    [self cancel];
    self.timer = nil;
}

-(void)dealloc
{
    NSLog(@"dealloc");
}

@end
