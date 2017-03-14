//
//  UIView+DWViewUtils.h
//  a
//
//  Created by Wicky on 2017/3/13.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DWViewFrameUtils)
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

@interface UIView (DWViewHierarchyUtils)

/**
 是否在屏幕中，即是否在可显示层级中
 
 当view与屏幕frame有交集且hidden为NO，alpha不为0时等一切可视情况（被完全遮盖也视作可视情况）为YES，其他为NO
 */
@property (nonatomic ,assign ,readonly,getter=isInScreen) BOOL inScreen;

@end

@interface UIView (DWViewDecorateUtils)

///添加线
-(void)dw_AddLineWithFrame:(CGRect)frame color:(UIColor *)color;

///添加圆角
-(void)dw_AddCorner:(UIRectCorner)corners radius:(CGFloat)radius;

@end
