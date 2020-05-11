//
//  DWDispatcher.h
//  DWDispatcher
//
//  Created by Wicky on 2019/9/26.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DWDispatcherHandler)(NSArray * items);

@interface DWDispatcher : NSObject

@property (nonatomic ,assign ,readonly) NSTimeInterval timeInterval;

@property (nonatomic ,assign ,readonly) BOOL onService;

@property (nonatomic ,assign ,readonly) NSInteger idleTimesToHangUp;

+(instancetype)dispatcherWithTimeInterval:(NSTimeInterval)timeInterval idleTimesToHangUp:(NSInteger)idleTimes handler:(DWDispatcherHandler)handler;

-(void)dispatchObject:(id)object;

@end

NS_ASSUME_NONNULL_END
