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
 
 version 1.0.2
 添加多分组模式
 
 version 1.0.3
 添加选择模式及相关api
 
 version 1.0.4
 添加helper设置cell类型及复用标识
 
 version 1.0.5
 将cell的基础属性提出协议，helper与model同时遵守协议
 
 version 1.0.6
 修正占位视图展示时机，提供两个刷新列表扩展方法，提供展示、隐藏占位图接口
 
 version 1.0.7
 添加选则模式下单选多选控制
 */

#import <UIKit/UIKit.h>

#pragma mark --- tableView 代理映射 ---
@class DWTableViewHelper;
@protocol DWTableViewHelperDelegate <NSObject>

@optional
-(void)dw_TableView:(__kindof UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
-(UIView *)dw_TableView:(__kindof UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(UIView *)dw_TableView:(__kindof UITableView *)tableView viewForFooterInSection:(NSInteger)section;
-(void)dw_TableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)dw_TableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell *)dw_TableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)dw_TableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(NSInteger)dw_NumberOfSectionsInTableView:(UITableView *)tableView;
-(void)dw_ScrollViewDidScroll:(UIScrollView *)scrollView;
-(UITableViewCellEditingStyle)dw_TableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark --- cell 基础属性协议---
@protocol DWTableViewHelperCellProperty <NSObject>
/**
 通过helper设置为批量设置，优先级较低；通过model设置为特殊设置，优先级较高。
 可通过helper批量设置后针对特殊cell通过model单独设置属性。
 */

///cell类型与复用标识
/**
 优先级：映射代理 > 数据模型 > helper
 
 cell类型与复用标识两者必须同时在helper或model中至少设置一次。
 若helper及model中均设置正确则model中优先级更高
 
 通过helper设置cell类型与复用标识更加适用于以下场景：
 需要共享数据模型但是要展示不同种类cell的场景
 
 此时需要手动将model中cell类型或者复用标识置为nil（理论上两者均存在默认值所以需要置nil）并通过helper进行指定cell类型
 */
///cell类型
@property (nonatomic ,copy) NSString * cellClassStr;

///复用标识
@property (nonatomic ,copy) NSString * cellID;

///helper行高
/**
 优先级：映射代理行高 > 数据模型行高 > helper行高 > 默认行高44
 */
@property (nonatomic ,assign) CGFloat cellRowHeight;

///选中模式图标
/**
 优先级：数据模型图片 > helper图片 > 系统默认图标

 若设置helper图片后，model设置图片不受影响，未设置图片的model将会被设置为helper图片。
 若通过helper批量设置后，个别cell要使用系统默认图标，请将对应model的图片设置为nil。
 */
///选择模式选中图标
@property (nonatomic ,strong) UIImage * cellEditSelectedIcon;

///选择模式未选中图标
@property (nonatomic ,strong) UIImage * cellEditUnselectedIcon;

@end

#pragma mark --- DWTableViewHelper 工具类 ---
@class DWTableViewHelperModel;
/**
 Helper工具类
 */
@interface DWTableViewHelper : NSObject<DWTableViewHelperCellProperty>

///代理
@property (nonatomic ,weak) id<DWTableViewHelperDelegate> helperDelegate;

///数据源
@property (nonatomic ,strong) NSArray * dataSource;

///自动绘制分割线
@property (nonatomic ,assign) BOOL needSeparator;

///分割线距屏幕两侧宽度
@property (nonatomic ,assign) CGFloat separatorMargin;

///无数据占位图
@property (nonatomic ,strong) UIView * placeHolderView;

///多分组模式
@property (nonatomic ,assign) BOOL multiSection;

///设置是否为选择模式
@property (nonatomic ,assign) BOOL selectEnable;

///是否允许多选
@property (nonatomic ,assign) BOOL multiSelect;

///返回被选中的cell的indexPath的数组
@property (nonatomic ,strong) NSArray * selectedRows;

///实例化方法
-(instancetype)initWithTabV:(__kindof UITableView *)tabV dataSource:(NSArray *)dataSource;

///刷新列表同时自动处理占位图
-(void)reloadDataAndHandlePlaceHolderView;

///刷新列表并在完成时进行回调
-(void)reloadDataWithCompletion:(void(^)())completion;

///展示占位图
-(void)showPlaceHolderView;

///隐藏占位图
-(void)hidePlaceHolderView;

///设置全部选中或取消全部选中
-(void)setAllSelect:(BOOL)select;

///设置指定分组全部选中或取消全部选中
-(void)setSection:(NSUInteger)section allSelect:(BOOL)select;

///反选指定分组
-(void)invertSelectSection:(NSUInteger)section;

///反选全部
-(void)invertSelectAll;
@end

#pragma mark --- DWTableViewHelperModel 数据模型基类 ---
/**
 基础Model类
 
 数据模型请继承自本类
 本类所有属性、方法均为统一接口，子类可重写方法，注意调用父类实现
 */
@interface DWTableViewHelperModel : NSObject<DWTableViewHelperCellProperty>

@end

#pragma mark --- DWTableViewHelperCell cell基类 ---
/**
 基础Cell类
 
 Cell请继承自本类
 本类所有属性、方法均为统一接口，子类可重写方法，注意调用父类实现
 */
@interface DWTableViewHelperCell : UITableViewCell

///数据模型
@property (nonatomic ,strong)__kindof DWTableViewHelperModel * model;

///设置子视图
-(void)setupUI;

///设置子视图约束
-(void)setupConstraints;
@end
