//
//  DWOperationCancelFlag.m
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#ifndef __DW__Debug__
#define __DW__Debug__
#endif

#import "DWOperationCancelFlag.h"
#import <libkern/OSAtomic.h>

@interface DWOperationCancelFlag ()

@property (atomic ,readonly) int32_t signal;

@end

@implementation DWOperationCancelFlag

-(void)start {
    int32_t current = self.signal;
    self.cancelFlag = ^BOOL(){
#ifdef __DW__Debug__
        if (self.signal != current) {
            NSLog(@"will cancel operation at %d",current);
        }
#endif
        return (self.signal != current);
    };
}

-(void)cancel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    OSAtomicIncrement32(&_signal);
#pragma clang diagnostic pop
}

-(CancelFlag)settleAnCancelFlag {
    return [self.cancelFlag copy];
}

-(CancelFlag)restartAnCancelFlag {
    [self cancel];
    [self start];
    return [self settleAnCancelFlag];
}

@end
