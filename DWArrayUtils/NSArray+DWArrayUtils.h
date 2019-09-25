//
//  NSArray+DWArrayUtils.h
//  tableview
//
//  Created by Wicky on 2017/1/29.
//  Copyright © 2017年 sf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^DWFilter)(id obj, NSUInteger idx,NSUInteger count,BOOL * stop);
/**
 处理数组过滤相关
 */
@interface NSArray (DWArrayFilterUtils)
///根据block过滤数组
/**
 filter  返回保留条件的filter
 
 e.g.
 return obj.length > 0;
 则返回数组中长度大于0的字符串组成的数组
 
 参数解析：
 obj    将要过滤的对象
 idx    将要过滤的对象在原数组中的序列
 count  目标数组中当前容量
 stop   是否停止过滤，直接返回当前已过滤的目标数组
 */
-(NSArray *)dw_filteredArrayUsingFilter:(DWFilter)filter;

@end

@interface NSMutableArray (DWArrayFilterUtils)

-(void)dw_filterUsingFilter:(DWFilter)filter;

@end


/**
 处理数组集合相关
 */
@interface NSArray (DWArrayCollectionUtils)

///获取自身中相对arr的补集
/**
 block  返回判断对象相等的条件
 
 e.g.
 return [obj1 isEqualToString:obj2];
 则若两字符串相同，则排除，返回不相同字符串的数组
 */
-(NSArray *)dw_complementaryArrayWithArr:(NSArray *)arr usingEqualBlock:(BOOL(^)(id obj1,id obj2))block;

///获取arr中相对于自身的补集
-(NSArray *)dw_complementaryArrayFromArr:(NSArray *)arr usingEqualBlock:(BOOL(^)(id obj1,id obj2))block;

///将数组按数量分为多个数组
-(NSArray *)dw_splitArrayByCapacity:(NSUInteger)capacity;

@end

typedef NSComparisonResult(^DWComparator)(id obj1,id obj2);

/**
 以下两个宏可作为DWComparator类型数据直接返回
 */

///数字升序排列
#define DWComparatorNumberAscending \
(^(id obj1,id obj2) {\
if ([obj1 floatValue] < [obj2 floatValue]) {\
return NSOrderedAscending;\
} else {\
return NSOrderedDescending;\
}\
})


///数字降序排列
#define DWComparatorNumberDescending \
(^(id obj1,id obj2) {\
if ([obj1 floatValue] < [obj2 floatValue]) {\
    return NSOrderedDescending;\
} else {\
    return NSOrderedAscending;\
}\
})


/**
 处理数组排序相关
 */
@interface NSArray (DWArraySortUtils)

/**
 以堆排序进行排序

 @param comparator 比较器，见系统比较器用法
 @return 排序后数组
 */
-(NSArray *)dw_sortedArrayInHeapUsingComparator:(DWComparator)comparator;

@end

@interface NSMutableArray (DWArraySortUtils)


/**
 以堆排序进行排序

 @param comparator 比较器，见系统比较器用法
 */
-(void)dw_sortInHeapUsingComparator:(DWComparator)comparator;

@end


typedef NS_ENUM(NSUInteger, DWArrayKeyPathActionType) {
    DWArrayKeyPathActionTypeSum,///总数
    DWArrayKeyPathActionTypeAverage,///平均数
    DWArrayKeyPathActionTypeMaximum,///最大值
    DWArrayKeyPathActionTypeMinimum,///最小值
    DWArrayKeyPathActionTypeUnion,///对象的某一属性的集合，支持获取二维数组中某一对象的属性，二维数组按原数组结构分组，一位数组也可
    DWArrayKeyPathActionTypeDistinctUnion,///对象的某一属性的去重集合
    DWArrayKeyPathActionTypeUnionInArray,///仅支持二维数组，二维数组中某一属性的集合，返回一个数组
    DWArrayKeyPathActionTypeDistinctUnionInArray///同上，可去重
};

@interface NSArray (DWArrayKeyPathUtils)

/**
 返回集合中指定属性对应动作后的值

 @param path 属性
 @param action 动作
 @return 返回值
 
 注：path可为nil，则返回array自身的相应动作值
 */
-(id)dw_getObjectWithKeyPath:(NSString *)path action:(DWArrayKeyPathActionType)action;

@end


typedef NSComparisonResult(^DWSearchCondition)(id obj,NSUInteger currentIdx,BOOL * stop);

@interface NSArray (DWArraySearchUtils)

/**
 二分法查找数组中指定元素
 
 @param condition 对比条件
 - obj 当前找到元素
 - currentIdx 当前找到角标
 - *stop 是否停止查找
 
 eg. 在给定数组@[@1,@2,@3,@4,@5]中查找@2的角标
 
        NSArray * arr = @[@1,@2,@3,@4,@5];
        __block NSUInteger idx = NSNotFound;
        [arr dw_BinarySearchWithCondition:^NSComparisonResult(NSNumber * obj, NSUInteger currentIdx, BOOL *stop) {
            if ([obj isEqualToNumber:@2]) {
                idx = currentIdx;
                return NSOrderedSame;
            } else if ([obj integerValue] > 2) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }];
        if (idx == NSNotFound) {
            NSLog(@"未找到@2");
        } else {
            NSLog(@"元素@2的角标为%lu",idx);
        }
 
 注：
 1.当condition为nil的时候会立刻返回
 2.请确保被查找容器为有序容器
 3.当查找到所需元素时，返回NSOrderedSame以停止查找过程
 当未查找到所需元素时，返回NSOrderedAscending以检测角标较小的一侧
 当未查找到所需元素时，返回NSOrderedDescending以检测角标较大的一侧
 4.任何时候，可以通过修改stop为YES以停止查找过程
 */
-(void)dw_binarySearchWithCondition:(DWSearchCondition)condition;

@end

@interface NSArray (DWArrayLogUtils)

@end
