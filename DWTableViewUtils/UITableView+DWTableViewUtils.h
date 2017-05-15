//
//  UITableView+DWTableViewUtils.h
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWTableViewUtils
 
 提供TableView相关扩展方法
 
 version 1.0.0
 提供占位图、刷新列表扩展方法、占位图显隐相关api
 
 version 1.0.1
 提供indexPath计算api
 */

#import <UIKit/UIKit.h>

@interface UITableView (DWTableViewUtils)

///无数据占位图
@property (nonatomic ,strong) UIView * placeHolderView;

///刷新列表并获取刷新完成回调
-(void)reloadDataWithCompletion:(void(^)())completion;

///刷新列表同时自动处理占位图
-(void)reloadDataAndHandlePlaceHolderView;

///展示占位图
-(void)showPlaceHolderView;

///隐藏占位图
-(void)hidePlaceHolderView;

@end

@interface UITableView (DWTableViewIndexPathUtils)

///计算总项目数
-(NSUInteger)dw_TotalItems;

/**
 计算两个idxP之间的距离

 @param idxPA 第一个indexPath
 @param idxPB 第二个indexPath
 @return 距离
 
 注：
 距离有效值为非负数。
 返回-1说明无法完成计算，检验idxP的合法性及dataSource的有效性
 */
-(NSInteger)dw_DistanceBetweenIndexPathA:(NSIndexPath *)idxPA indexPathB:(NSIndexPath *)idxPB;

///计算idxP是否合法
-(BOOL)dw_IsValidIndexPath:(NSIndexPath *)idxP;


/**
 计算目标idxP周围指定个数的idxPs数组

 @param idxP 目标idxP
 @param isNext 顺序查找还是逆序查找
 @param count 指定个数
 @param step 步长（若小于1将被转化为1）
 @return 结果数组
 */
-(NSArray <NSIndexPath *>*)dw_IndexPathsAroundIndexPath:(NSIndexPath *)idxP nextOrPreivious:(BOOL)isNext count:(NSUInteger)count step:(NSInteger)step;
@end
