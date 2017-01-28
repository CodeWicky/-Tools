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
-(UITableViewCellEditingStyle)dw_TableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
@class DWTableViewHelperModel;

/**
 Helper工具类
 */
@interface DWTableViewHelper : NSObject

///代理
@property (nonatomic ,weak) id<DWTableViewHelperDelegate> helperDelegate;

///数据源
@property (nonatomic ,strong) NSArray * dataSource;

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

///多分组模式
@property (nonatomic ,assign) BOOL multiSection;

///设置是否为选择模式
@property (nonatomic ,assign) BOOL selectEnable;

///返回被选中的cell的indexPath的数组
@property (nonatomic ,strong) NSArray * selectedRows;

///选中模式图标
/**
 优先级：model图片 > helper图片 > 系统默认图标
 
 通过helper设置为批量设置，优先级较低；通过model设置为特殊设置，优先级较高。
 若设置helper图片后，model设置图片不受影响，未设置图片的model将会被设置为helper图片。
 若通过helper批量设置后，个别cell要使用系统默认图标，请将对应model的图片设置为nil。
 */
///选择模式选中图标
@property (nonatomic ,strong) UIImage * cellEditSelectedIcon;

///选择模式未选中图标
@property (nonatomic ,strong) UIImage * cellEditUnselectedIcon;

///实例化方法
-(instancetype)initWithTabV:(__kindof UITableView *)tabV dataSource:(NSArray *)dataSource;

///设置全部选中或取消全部选中
-(void)setAllSelect:(BOOL)select;

///设置指定分组全部选中或取消全部选中
-(void)setSection:(NSUInteger)section allSelect:(BOOL)select;

///反选指定分组
-(void)invertSelectSection:(NSUInteger)section;

///反选全部
-(void)invertSelectAll;
@end

/**
 基础Model类
 
 数据模型请继承自本类
 本类所有属性、方法均为统一接口，子类可重写方法，注意调用父类实现
 */
@interface DWTableViewHelperModel : NSObject

///复用标识
@property (nonatomic ,copy) NSString * cellID;

///cell类型
@property (nonatomic ,copy) NSString * cellClassStr;

///行高
@property (nonatomic ,assign) CGFloat cellRowHeight;

///cell选中状态图标
@property (nonatomic ,strong) UIImage * cellEditSelectedIcon;

///cell非选中状态图标
@property (nonatomic ,strong) UIImage * cellEditUnselectedIcon;
@end

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
