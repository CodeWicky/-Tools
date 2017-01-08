//
//  DWRangeUtils.h
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWRangeUtils : NSObject
NSArray * DWRangeExcept(NSRange targetRange,NSRange exceptRange);
@end
