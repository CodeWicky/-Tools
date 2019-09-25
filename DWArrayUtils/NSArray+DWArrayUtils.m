//
//  NSArray+DWArrayUtils.m
//  tableview
//
//  Created by Wicky on 2017/1/29.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "NSArray+DWArrayUtils.h"

@implementation NSArray (DWArrayFilterUtils)

-(NSArray *)dw_filteredArrayUsingFilter:(DWFilter)filter {
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

-(void)dw_filterUsingFilter:(DWFilter)filter {
    NSArray * array = [NSArray arrayWithArray:self];
    [self removeAllObjects];
    filterArr(array, self, filter);
}

@end

@implementation NSArray (DWArrayCollectionUtils)

-(NSArray *)dw_complementaryArrayWithArr:(NSArray *)arr usingEqualBlock:(BOOL (^)(id,id))block
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

-(NSArray *)dw_complementaryArrayFromArr:(NSArray *)arr usingEqualBlock:(BOOL (^)(id,id))block
{
    return [arr dw_complementaryArrayWithArr:self usingEqualBlock:block];
}

-(NSArray *)dw_splitArrayByCapacity:(NSUInteger)capacity
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

-(NSArray *)dw_sortedArrayInHeapUsingComparator:(DWComparator)comparator {
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

-(void)dw_sortInHeapUsingComparator:(DWComparator)comparator {
    sortHeap(self, comparator);
}

@end

@implementation NSArray (DWArrayKeyPathUtils)

-(id)dw_getObjectWithKeyPath:(NSString *)path action:(DWArrayKeyPathActionType)action {
    if (action == DWArrayKeyPathActionTypeUnionInArray || action == DWArrayKeyPathActionTypeDistinctUnionInArray) {
        BOOL isArray = YES;
        for (id obj in self) {
            if (![obj isKindOfClass:[NSArray class]]) {
                isArray = NO;
            }
        }
        if (!isArray) {
            NSAssert(NO, @"to use %ld action you should make sure the array is made up of NSArray",action);
            return nil;
        }
    }
    NSString * actionStr = StringFromAction(action);
    if (!actionStr.length) {
        NSAssert(NO, @"cannot perform an action on %ld",action);
        return nil;
    }
    if (!path.length) {
        path = @"self";
    }
    return [self valueForKeyPath:[NSString stringWithFormat:@"%@%@",actionStr,path]];
}

static inline NSString * StringFromAction(DWArrayKeyPathActionType action) {
    switch (action) {
        case DWArrayKeyPathActionTypeSum:
            return @"@sum.";
        case DWArrayKeyPathActionTypeAverage:
            return @"@avg.";
        case DWArrayKeyPathActionTypeMaximum:
            return @"@max.";
        case DWArrayKeyPathActionTypeMinimum:
            return @"@min.";
        case DWArrayKeyPathActionTypeUnion:
            return @"@unionOfObjects.";
        case DWArrayKeyPathActionTypeDistinctUnion:
            return @"@distinctUnionOfObjects.";
        case DWArrayKeyPathActionTypeUnionInArray:
            return @"@unionOfArrays.";
        case DWArrayKeyPathActionTypeDistinctUnionInArray:
            return @"@distinctUnionOfArrays.";
        default:
            return nil;
    }
}

@end

@implementation NSArray (DWArraySearchUtils)

-(void)dw_binarySearchWithCondition:(DWSearchCondition)condition {
    if (!condition || self.count == 0) {
        return;
    }
    NSUInteger hR = self.count - 1;
    NSUInteger lR = 0;
    NSUInteger mR = 0;
    BOOL stop = NO;
    while (lR <= hR) {
        mR = (hR + lR) / 2;
        NSComparisonResult result = condition(self[mR],mR,&stop);
        if (result == NSOrderedSame || stop == YES) {
            break;
        } else if (result == NSOrderedAscending) {
            if (mR == 0) {
                break;
            } else {
                hR = mR - 1;
            }
        } else {
            if (mR == self.count - 1) {
                break;
            } else {
                lR = mR + 1;
            }
        }
    }
}

@end

@implementation NSArray (DWArrayLogUtils)

-(NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSString * footerBlank = @"";
    for (int i = 0; i < level; i++) {
        footerBlank = [footerBlank stringByAppendingString:@"\t"];
    }
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"("];
    NSString * contentBlank = [footerBlank stringByAppendingString:@"\t"];
    for (id obj in self) {
        id value = obj;
        if ([value respondsToSelector:@selector(descriptionWithLocale:indent:)]) {
            value = [value descriptionWithLocale:locale indent:level + 1];
        }
        [str appendFormat:@"\n%@%@,",contentBlank,value];
    }
    if (self.count) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    }
    [str appendString:[NSString stringWithFormat:@"\n%@)",footerBlank]];
    return str;
}

@end
