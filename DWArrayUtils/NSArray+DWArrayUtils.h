//
//  NSArray+DWArrayUtils.h
//  tableview
//
//  Created by Wicky on 2017/1/29.
//  Copyright © 2017年 sf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DWArrayUtils)
-(NSArray *)filterObjectsUsingBlock:(BOOL(^)(id obj, NSUInteger idx,NSUInteger count,BOOL * stop))block;
@end
