//
//  DWOperationCancelFlag.h
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#define CancelFlag(flag) flag.cancelFlag()

#import <Foundation/Foundation.h>

typedef BOOL (^CancelFlag)();

@interface DWOperationCancelFlag : NSObject

@property (nonatomic ,copy) CancelFlag cancelFlag;

///开始任务
-(void)start;

///取消任务
-(void)cancel;

///设置一个返回标志
-(CancelFlag)settleAnCancelFlag;

///重设一个取消标志
-(CancelFlag)restartAnCancelFlag;

@end
