//
//  DWTransaction.h
//  hgfd
//
//  Created by Wicky on 2017/2/25.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWTransaction
 事物类，处理任务执行时机
 
 空闲提交源码修改自YYTextTransaction/ASDK
 
 version 1.0.0
 添加事务空闲提交方法
 
 version 1.0.1
 添加事务延时方法
 
 version 1.0.2
 添加任务等待方法
 */

#import <Foundation/Foundation.h>

@interface DWTransaction : NSObject

/**
 将事务添加至runloop空闲时提交

 类方法生产实例后调用commit提交
 
 注：
 1.任务执行完成或之前会实例持有自己本身以防止实例提前释放
 2.执行或取消之后实例释放自身的持有，此时若实例引用计数为零，在下一次runloop时实例将被释放。
 3.实例本身会持有target以防任务执行之前target被释放
 4.commit方法应配合+dw_TransactionWith...方法使用
*/
+(instancetype)transactionWithCompletion:(dispatch_block_t)completion;
+(instancetype)transactionWithTarget:(id)target selector:(SEL)selector;
+(instancetype)transactionWithTarget:(id)target selector:(SEL)selector withObject:(id)object;
-(void)commit;

@end

@interface DWTransaction (Wait)

/**
 添加延时执行事务，可立即执行也可取消执行
 
 注：
 1.timeout 传入小于或等于0的数值时将等待run调用在执行
 2.任务执行完成或取消之前会实例持有自己本身以防止实例提前释放
 3.执行或取消之后实例释放自身的持有，此时若实例引用计数为零，在下一次runloop时实例将被释放。
 4.实例本身会持有target以防任务执行之前target被释放
 5.run/cancel/cancelWithHandler方法应配合+dw_Wait...方法使用
 */
+(instancetype)waitUtil:(NSTimeInterval)timeout completion:(dispatch_block_t)completion;
+(instancetype)waitWithCompletion:(dispatch_block_t)completion;
+(instancetype)waitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector;
+(instancetype)waitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector object:(id)object;
+(instancetype)waitWithTarget:(id)target selector:(SEL)selector;
+(instancetype)waitWithTarget:(id)target selector:(SEL)selector object:(id)object;
-(void)run;
-(void)cancel;
-(void)cancelWithHandler:(dispatch_block_t)handler;

/**
 释放target的持有
 
 为任务确保执行实例会持有target，当任务完成或取消时会释放对target的持有。
 若任务未执行则不会释放，为避免循环引用的产生，此时应调用-invalidate释放对target的持有
 */
-(void)invalidate;

@end

@interface DWTransaction (MissionComlpetion)

/**
 配置任务等待实例，所有任务完成时调用完成回调。
 适用于想在几个并行任务完成后再触发回调时使用。
 内部维护一个计数器，初始值为0，调用 -startAnMission 时计数器加一，调用 -finishAnMission 时计数器减一，当计数器为零时触发回调。
 
 注：
 1.计数器不为0时实例持有自己本身以防止实例提前释放
 2.计数器为0时自身的持有，此时若实例引用计数为零，在下一次runloop时实例将被释放。
 3. -addMissionCompletionHandler 可添加完成时的回调动作。
 */
+(instancetype)configWithMissionCompletionHandler:(dispatch_block_t)completion;
-(void)addMissionCompletionHandler:(dispatch_block_t)completion;
-(void)startAnMission;
-(void)finishAnMission;

@end
