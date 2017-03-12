//
//  NSArray+DWArrayUtils.m
//  tableview
//
//  Created by Wicky on 2017/1/29.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "NSArray+DWArrayUtils.h"

@implementation NSArray (DWArrayFilterUtils)

-(NSArray *)dw_FilteredArrayUsingFilter:(DWFilter)filter {
    NSMutableArray * array = [NSMutableArray array];
    filterArr(self,array,filter);
    return array.copy;
}

#pragma mark --- Filter Array Method ---
static inline void filterArr (NSArray * oriArr,NSMutableArray * desArr,DWFilter filter) {
    [oriArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (filter(obj,idx,desArr.count,stop)) {
            [desArr addObject:obj];
        }
    }];
}

@end

@implementation NSMutableArray (DWArrayFilterUtils)

-(void)dw_FilterUsingFilter:(DWFilter)filter {
    NSArray * array = [NSArray arrayWithArray:self];
    [self removeAllObjects];
    filterArr(array, self, filter);
}

@end

@implementation NSArray (DWArrayCollectionUtils)

-(NSArray *)dw_ComplementaryArrayWithArr:(NSArray *)arr usingEqualBlock:(BOOL (^)(id,id))block
{
    NSMutableArray * array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL contain = NO;
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            contain = block(obj1,obj2);
            if (contain) {
                *stop = YES;
            }
        }];
        if (!contain) {
            [array addObject:obj1];
        }
    }];
    return array.copy;
}

-(NSArray *)dw_ComplementaryArrayFromArr:(NSArray *)arr usingEqualBlock:(BOOL (^)(id,id))block
{
    return [arr dw_ComplementaryArrayWithArr:self usingEqualBlock:block];
}

-(NSArray *)dw_SplitArrayByCapacity:(NSUInteger)capacity
{
    if (capacity == 0) {
        return nil;
    }
    NSMutableArray * arr = [NSMutableArray array];
    NSMutableArray * arrTemp = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx && (idx % capacity == 0)) {
            [arr addObject:[arrTemp copy]];
            [arrTemp removeAllObjects];
        }
        [arrTemp addObject:obj];
    }];
    [arr addObject:arrTemp];
    return arr.copy;
}

@end

@implementation NSArray (DWArraySortUtils)

-(NSArray *)dw_SortedArrayInHeapUsingComparator:(DWComparator)comparator {
    NSMutableArray * array = [NSMutableArray arrayWithArray:self];
    sortHeap(array, comparator);
    return array.copy;
}

#pragma mark --- Heap Sort Method ---
static inline NSUInteger leftLeaf(NSUInteger i) {
    return 2 * i + 1;
}

static inline NSUInteger rightLeaf(NSUInteger i) {
    return 2 * (i + 1);
}

static inline void swapArr (NSMutableArray * arr,NSUInteger m,NSUInteger n) {
    if (m >= arr.count || n > arr.count) {
        return;
    }
    id temp = arr[m];
    arr[m] = arr[n];
    arr[n] = temp;
}

static inline void maxHeap (NSMutableArray * arr,NSUInteger idx,NSUInteger len,DWComparator comparator) {
    NSUInteger m = leftLeaf(idx);
    NSUInteger n = rightLeaf(idx);
    NSUInteger max = idx;
    if (m < len && (comparator(arr[idx],arr[m]) == NSOrderedAscending)) {
        max = m;
    }
    if (n < len && (comparator(arr[max],arr[n]) == NSOrderedAscending)) {
        max = n;
    }
    if (max != idx) {
        swapArr(arr, idx, max);
        maxHeap(arr, max,len,comparator);
    }
}

static inline void buildMaxHeap (NSMutableArray * arr,DWComparator comparator) {
    for (NSInteger i = arr.count / 2 + 1;i >= 0;i --) {
        maxHeap(arr, i,arr.count,comparator);
    }
}

static inline void sortHeap (NSMutableArray * arr,DWComparator comparator) {
    buildMaxHeap(arr, comparator);
    NSInteger count = arr.count;
    while (count > 0) {
        swapArr(arr, 0, count - 1);
        count -- ;
        maxHeap(arr, 0, count,comparator);
    }
}

@end

@implementation NSMutableArray (DWArraySortUtils)

-(void)dw_SortInHeapUsingComparator:(DWComparator)comparator {
    sortHeap(self, comparator);
}

@end
