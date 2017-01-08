//
//  DWRangeUtils.m
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWRangeUtils.h"

@implementation DWRangeUtils
NSArray * DWRangeExcept(NSRange targetRange,NSRange exceptRange){
    NSRange interRange = NSIntersectionRange(targetRange, exceptRange);
    if (interRange.length == 0) {
        return nil;
    }
    else if (NSEqualRanges(targetRange, interRange))
    {
        return nil;
    }
    NSMutableArray * arr = [NSMutableArray array];
    
    if (interRange.location > targetRange.location) {
        [arr addObject:[NSValue valueWithRange:NSMakeRange(targetRange.location, interRange.location - targetRange.location)]];
    }
    if (NSMaxRange(targetRange) > NSMaxRange(interRange)) {
        [arr addObject:[NSValue valueWithRange:NSMakeRange(NSMaxRange(interRange), NSMaxRange(targetRange) - NSMaxRange(interRange))]];
    }
    return arr.copy;
};
@end
