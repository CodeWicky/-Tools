//
//  DWTableViewHelper.h
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/13.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWTableViewHelper
 TableView工具类
 抽出TableView代理，减小VC压力，添加常用代理映射
 
 version 1.0.0
 添加常用代理映射
 添加helper基础属性
 
 version 1.0.1
 去除注册，改为更适用的重用模式
 */

#import <UIKit/UIKit.h>

@class DWTableViewHelper;
@protocol DWTableViewHelperDelegate <NSObject>

@optional
-(void)dw_TableView:(__kindof UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(UIView *)dw_TableView:(__kindof UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(UIView *)dw_TableView:(__kindof UITableView *)tableView viewForFooterInSection:(NSInteger)section;
-(void)dw_TableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)dw_TableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell *)dw_TableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)dw_TableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(NSInteger)dw_NumberOfSectionsInTableView:(UITableView *)tableView;
-(void)dw_ScrollViewDidScroll:(UIScrollView *)scrollView;
@end
@class DWTableViewHelperModel;

/**
 Helper工具类
 */
@interface DWTableViewHelper : NSObject
@property (nonatomic ,weak) id<DWTableViewHelperDelegate> helperDelegate;
@property (nonatomic ,strong) NSArray<DWTableViewHelperModel *> * dataSource;

///自动绘制分割线
@property (nonatomic ,assign) BOOL needSeparator;

///分割线距屏幕两侧宽度
@property (nonatomic ,assign) CGFloat separatorMargin;

///helper行高
/**
 优先级：映射代理行高 > 数据模型行高 > helper行高 > 默认行高44
 */
@property (nonatomic ,assign) CGFloat rowHeight;

///无数据占位图
@property (nonatomic ,strong) UIView * placeHolderView;

///实例化方法
-(instancetype)initWithTabV:(__kindof UITableView *)tabV dataSource:(NSArray *)dataSource;
@end

/**
 基础Model类
 
 数据模型请继承自本类
 */
@interface DWTableViewHelperModel : NSObject
@property (nonatomic ,copy) NSString * cellID;
@property (nonatomic ,copy) NSString * cellClassStr;
@property (nonatomic ,assign) CGFloat cellRowHeight;
@end

/**
 基础Cell类
 
 Cell请继承自本类
 */
@interface DWTableViewHelperCell : UITableViewCell
@property (nonatomic ,strong)__kindof DWTableViewHelperModel * model;
-(void)setupUI;
-(void)setupConstraints;
@end
