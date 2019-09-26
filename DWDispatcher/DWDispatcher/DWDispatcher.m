//
//  DWDispatcher.m
//  DWDispatcher
//
//  Created by Wicky on 2019/9/26.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWDispatcher.h"

@interface DWDispatcher ()

@property (nonatomic ,copy) DWDispatcherHandler handler;

@end

@implementation DWDispatcher

#pragma mark --- interface method ---
+(instancetype)dispatcherWithTimeInterval:(NSTimeInterval)timeInterval handler:(DWDispatcherHandler)handler {
    return [[DWDispatcher alloc] initWithTimeInterval:timeInterval handler:handler];
}

-(void)dispatchObject:(id)object {
    
}

#pragma mark --- tool method ---
-(instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval handler:(DWDispatcherHandler)handler {
    if (self = [super init]) {
        _timeInterval = timeInterval;
        _handler = handler;
    }
    return self;
}

@end
