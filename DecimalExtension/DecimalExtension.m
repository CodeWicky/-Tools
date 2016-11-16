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
    return roundf(x * pow10x(y)) * 1.0 / pow10x(y);
}
CGFloat ceilX(CGFloat x,int y){
    return ceilf(x * pow10x(y)) * 1.0 / pow10x(y);
}
CGFloat floorX(CGFloat x,int y){
    return floorf(x * pow10x(y)) * 1.0 / pow10x(y);
}
int pow10x(int x){
    return pow(10, x);
}
CGFloat powX2(CGFloat x){
    return pow(x, 2);
}
CGFloat powX3(CGFloat x){
    return pow(x, 3);
}
CGFloat avr(CGFloat x,CGFloat y){
    return (x + y) / 2.0;
}
CGFloat radianFromDegree(CGFloat degree){
    return degree / 180.0 * M_PI;
}
CGFloat degreeFromRadian(CGFloat radian){
    return radian / M_PI * 180.0;
}
CGFloat angleFromCosinesLaw(CGFloat a,CGFloat b,CGFloat c){
    CGFloat min1 = MIN(a, b);
    CGFloat max1 = MAX(a, b);
    CGFloat min2 = MIN(max1, c);
    CGFloat max = MAX(max1, c);
    if (min1 + min2 <= max) {
        return -1;
    }
    return acosf((powX2(a) + powX2(b) - powX2(c)) / (2 * a * b));
}
CGFloat lengthFromCosinesLaw(CGFloat a,CGFloat b,CGFloat alpha){
    if (alpha < 0 || alpha > M_PI) {
        return -1;
    }
    return sqrtf(powX2(a) + powX2(b) - 2 * a * b * cosf(alpha));
}
CGFloat angleFromTwoPoint(CGFloat x1,CGFloat y1,CGFloat x2,CGFloat y2){
    CGFloat deltaX = x2 - x1;
    CGFloat deltaY = y2 - y1;
    CGFloat length = sqrtf(powX2(deltaX) + powX2(deltaY));
    if (deltaY > 0) {
        return acosf(deltaX / length);
    }
    else if (deltaY == 0)
    {
        if (deltaX >= 0) {
            return 0;
        }
        else
        {
            return M_PI;
        }
    }
    else
    {
        return M_PI + acosf(deltaX / length);
    }
}
@end
