//
//  DWRangeUtils.h
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWRangeUtils : NSObject
///返回目标范围内排除一定范围后的范围数组
NSArray * DWRangeExcept(NSRange targetRange,NSRange exceptRange);
@end
