//
//  DecimalExtension.h
//  DWHUD
//
//  Created by Wicky on 16/10/25.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/*
 DecimalExtension
 
 补充一些数学运算
 */
#import <UIKit/UIKit.h>
@interface DecimalExtension : NSObject
/*
 x按四舍五入保留y位小数
 */
CGFloat roundX(CGFloat x,int y);
/*
 x按五入保留y位小数
 */
CGFloat ceilX(CGFloat x,int y);
/*
 x按四舍保留y位小数
 */
CGFloat floorX(CGFloat x,int y);
/*
 返回10的x次方
 */
int pow10(int x);
@end
