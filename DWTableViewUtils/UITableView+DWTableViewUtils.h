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
