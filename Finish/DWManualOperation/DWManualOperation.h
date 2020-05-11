//
//  DWManualOperation.h
//  a
//
//  Created by Wicky on 2018/1/17.
//  Copyright © 2018年 Wicky. All rights reserved.
//
/**
    DWManualOperation
    手动完成任务类
 
    继承自NSOperation，重写 isExecuting 和 isFinished 两个状态的改变机制。
 
    每添加一个任务会将 DWManualOperation 类内部维护的任务计数器加一，每调用 -handlerDone 时任务计数器减一，当任务计数器为0时自动改变operation状态为完成状态。
 
    适用于为将异步任务封装在DWManualOperation中后自行控制任务被标记为完成状态的时机。
    可用于多个异步任务实际完成后触发另一个任务的情况。例如两个请求任务均结束后再进行数据刷新。
    同时可与 NSOperation 的其他子类配合再 NSOperationQueue 中使用。
 
    version 1.0.0
    提供基本功能，提供控制任务完成时机接口，提供直接完成任务接口。
 
    version 1.0.1
    提供任务回调串并行接口，以便控制回调的调用方式。
 
    version 1.0.2
    改变任务完成时释放自身时机至任务完成回调后释放自身。
 */

#import <Foundation/Foundation.h>

@class DWManualOperation;
typedef void(^OperationHandler)(DWManualOperation * op);
@interface DWManualOperation : NSOperation

///是否已并行模式调用回调，默认为真
@property (nonatomic ,assign) BOOL concurrentHandler;

/**
 以需要实现的任务生成operation对象

 @param handler 需要实现的任务
 @return operation实例
 
 @disc 调用 -start 方法后会统计任务总数并将任务计数器置为总数
 */
+(instancetype)manualOperationWithHandler:(OperationHandler)handler;

/**
 为operation对象添加任务

 @param handler 需要添加的任务
 
 @disc 1.调用 -start 方法后会统计任务总数并将任务计数器置为总数
       2.当 operation 的 isExecuting 或 isFinished 为 YES 时本方法将不执行任何操作。
 */
-(void)addExecutionHandler:(OperationHandler)handler;


/**
 将任务计数器数值减1。
 
 @disc 1.当任务计数器为0时不执行任何操作。
       2.当前任务正在进行或已经完成时不执行任何操作。
       3.当调用 -handlerDone 后若减1后计数器为0将会置当前任务 isExecuting 为 NO,isFinished 为 YES。即标志当前任务完成
 */
-(void)handlerDone;

/**
 立刻将当前任务标识为完成状态，isExecuting 为 NO,isFinished 为 YES。
 */
-(void)finishOperation;

@end
