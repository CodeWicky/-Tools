//
//  DWOperationCancelFlag.m
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWOperationCancelFlag.h"
#import <libkern/OSAtomic.h>

@interface DWOperationCancelFlag ()

@property (atomic ,readonly) int32_t signal;

@end

@implementation DWOperationCancelFlag

-(void)start {
    int32_t current = self.signal;
    self.cancelFlag = ^BOOL(){
        return (self.signal != current);
    };
}

-(void)cancel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    OSAtomicIncrement32(&_signal);
#pragma clang diagnostic pop
}

@end
