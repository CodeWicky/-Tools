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
+(instancetype)dw_TransactionWithCompletion:(dispatch_block_t)completion;
+(instancetype)dw_TransactionWithTarget:(id)target selector:(SEL)selector;
+(instancetype)dw_TransactionWithTarget:(id)target selector:(SEL)selector withObject:(id)object;
-(void)commit;

/**
 添加延时执行事务，可立即执行也可取消执行

 注：
 1.timeout 传入小于或等于0的数值时将等待run调用在执行
 2.任务执行完成或取消之前会实例持有自己本身以防止实例提前释放
 3.执行或取消之后实例释放自身的持有，此时若实例引用计数为零，在下一次runloop时实例将被释放。
 4.实例本身会持有target以防任务执行之前target被释放
 5.run/cancel/cancelWithHandler方法应配合+dw_Wait...方法使用
 */
+(instancetype)dw_WaitUtil:(NSTimeInterval)timeout completion:(dispatch_block_t)completion;
+(instancetype)dw_WaitWithCompletion:(dispatch_block_t)completion;
+(instancetype)dw_WaitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector;
+(instancetype)dw_WaitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector object:(id)object;
+(instancetype)dw_WaitWithTarget:(id)target selector:(SEL)selector;
+(instancetype)dw_WaitWithTarget:(id)target selector:(SEL)selector object:(id)object;
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
