//
//  UIView+Frame.h
//  UIView(Point)
//
//  Created by Wicky on 16/8/19.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)
@property (nonatomic ,assign) CGFloat originX;
@property (nonatomic ,assign) CGFloat originY;
@property (nonatomic ,assign) CGFloat width;
@property (nonatomic ,assign) CGFloat height;
@property (nonatomic ,assign ,readonly) CGFloat top;
@property (nonatomic ,assign ,readonly) CGFloat bottom;
@property (nonatomic ,assign ,readonly) CGFloat left;
@property (nonatomic ,assign ,readonly) CGFloat right;
@property (nonatomic ,assign) CGPoint topRightPoint;
@property (nonatomic ,assign) CGPoint bottomLeftPoint;
@property (nonatomic ,assign) CGPoint bottomRightPoint;
@property (nonatomic ,assign ,readonly) CGPoint centerOfSelf;
@property (nonatomic ,assign) CGFloat viewCornerR;
-(void)setOrigin:(CGPoint)origin;
-(void)setSize:(CGSize)size;
@end
