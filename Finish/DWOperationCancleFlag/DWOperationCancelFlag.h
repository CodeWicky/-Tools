//
//  DWOperationCancelFlag.h
//  hgfd
//
//  Created by Wicky on 2017/2/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/*
 DWOperationCancelFlag
 
 任务取消标志位。
 通过Block捕获变量的机制来判断任务是否被取消。
 
 DWOperationCancelFlag本身属性中的cancelFlag可表示最近任务的取消状态。
 而通过 -settleAnCancelFlag 或 -restartAnCancelFlag 获取的标志位可以表示获取标志位时正在执行的任务当前的取消状态。详细使用方法见范例。
 
 注，获取标志位结果为真代表任务被取消了。
 */

#define CancelFlag(flag) flag.cancelFlag()

#import <Foundation/Foundation.h>

typedef BOOL (^CancelFlag)(void);

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
