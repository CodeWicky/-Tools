//
//  DWProtocolEnhancer.m
//  DWProtocolEnhancer
//
//  Created by Wicky on 2019/3/19.
//  Copyright © 2019 Wicky. All rights reserved.
//
#import "DWProtocolEnhancer.h"
#import <objc/runtime.h>

static NSMutableSet * protocol_ctn;
void dw_registProtocol(Class clazz) {
    if (!protocol_ctn) {
        protocol_ctn = [NSMutableSet set];
    }
    NSString * clazzStr = NSStringFromClass(clazz);
    NSString * ptlStr = [clazzStr substringToIndex:clazzStr.length - 14];
    [protocol_ctn addObject:ptlStr];
}

__attribute__((constructor)) static void dw_enhance_protocol() {
    unsigned classCount;
    Class *classes = objc_copyClassList(&classCount);
    int needHandledCount = (int)[protocol_ctn count];
    for (int i = 0; i < classCount; i ++) {
        Class class = classes[i];
        Class metaClass = object_getClass(class);

        unsigned protocolCount;
        Protocol * __unsafe_unretained *protocols = class_copyProtocolList(class, &protocolCount);
        int handledCount = 0;
        for (int j = 0; (j < protocolCount) && (handledCount < needHandledCount); j ++) {
            Protocol *protocol = protocols[j];
            NSString * ptlStr = NSStringFromProtocol(protocol);
            if (![protocol_ctn containsObject:ptlStr]) {
                continue;
            }
            Class tempClass = objc_getClass([NSString stringWithFormat:@"%@TemporaryClass",ptlStr].UTF8String);
            unsigned methodCount;
            Method *methods = class_copyMethodList(tempClass, &methodCount);
            for (int k = 0; k < methodCount; k ++) {
                Method method = methods[k];
                class_addMethod(class, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
            }
            free(methods);

            Class metaTempClass = object_getClass(tempClass);
            unsigned metaMethodCount;
            Method *metaMethods = class_copyMethodList(metaTempClass, &metaMethodCount);
            for (int k = 0; k < metaMethodCount; k ++) {
                Method method = metaMethods[k];
                class_addMethod(metaClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
            }
            free(metaMethods);
        }
        free(protocols);
    }
    free(classes);
}


