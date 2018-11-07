//
//  DWStaticView.h
//  Protocol
//
//  Created by Wicky on 2017/2/16.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 DWStaticView
 静态视图，旨在节省渲染性能来提高程序流畅性。
 视图中不具备外观变化的视图可以调用本类提供静态视图操作api。
 调用静态视图操作api添加的视图将不具备图层层级而是作为寄宿图绘制本实例中。
 外观会发生变化的视图可以调用UIView原本的视图操作api，则与UIView处理机制相同。
 
 开发者必须注意的是，静态视图是作为寄宿图直接绘制再本实例中，故所有静态视图层级关系按添加顺序维护，非静态视图同UIView中处理一样也保持按添加顺序维持层级关系，但所有静态视图层级关系低于非静态视图层级，与添加顺序无关。
 
 version 1.0.0
 静态视图初步完成，完成基本绘制功能
 
 version 1.0.2
 完善静态状态切换功能，添加插入视图接口，添加重绘接口
 */
@interface DWStaticView : UIView

@property (nonatomic ,assign) BOOL staticBackLayer;

@property (nonatomic ,strong ,readonly) NSArray<UIView *> * staticBackSubviews;

///添加背景静态视图
-(void)addStaticBackSubview:(UIView *)view;

///以角标插入视图
-(void)insertStaticBackSubview:(UIView *)view atIndex:(NSInteger)index;

///插入背景静态视图在指定视图之上
-(void)insertStaticBackSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview;

///插入背景静态视图在指定视图之下
-(void)insertStaticBackSubview:(UIView *)view belowSubview:(UIView *)siblingSubview;

///移除背景静态视图
-(void)removeStaticBackSubview:(UIView *)view;

///设置视图需要重绘（子视图frame发生改变时需要调用）
-(void)setNeedsRedrawStaticView;

@end
