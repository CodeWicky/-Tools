//
//  DWProtocolEnhancer.h
//  DWProtocolEnhancer
//
//  Created by Wicky on 2019/3/19.
//  Copyright © 2019 Wicky. All rights reserved.
//

/**
 为协议方法提供默认实现
 
 使用方法：
 1.声明协议
 2.在协议的.m文件中调用@dw_protocol(Test_P)
 # 其中Test_P为想要提供默认实现的协议名
 3.然后在其后实现要提供默认实现的协议方法
 4.追加@end
 */

#import <Foundation/Foundation.h>

#define dw_protocol_imp(ptl) \
@interface ptl##TemporaryClass : NSObject <ptl> \
@end \
@implementation ptl##TemporaryClass\
+(void)load {\
    dw_registProtocol([self class]);\
} \

void dw_registProtocol(Class clazz);
