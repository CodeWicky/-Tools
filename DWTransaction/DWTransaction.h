//
//  DWTransaction.h
//  hgfd
//
//  Created by Wicky on 2017/2/25.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWTransaction
 事物类，将任务与runloop空闲时提交
 
 源码修改自YYTextTransaction/ASDK
 */

#import <Foundation/Foundation.h>

@interface DWTransaction : NSObject

+(instancetype)dw_TransactionWithTarget:(id)target selector:(SEL)selector;

-(void)commit;

@end
