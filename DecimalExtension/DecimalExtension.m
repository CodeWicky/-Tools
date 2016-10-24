//
//  DecimalExtension.m
//  DWHUD
//
//  Created by Wicky on 16/10/25.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DecimalExtension.h"

@implementation DecimalExtension
CGFloat roundX(CGFloat x,int y){
    return roundf(x * pow10(y)) * 1.0 / pow10(y);
}
CGFloat ceilX(CGFloat x,int y){
    return ceilf(x * pow10(y)) * 1.0 / pow10(y);
}
CGFloat floorX(CGFloat x,int y){
    return floorf(x * pow10(y)) * 1.0 / pow10(y);
}
int pow10(int x){
    return pow(10, x);
}
@end
