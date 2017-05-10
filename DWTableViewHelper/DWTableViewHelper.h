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
 
 version 1.0.8
 补充组头视图、尾视图行高代理映射并简化代理链
 
 version 1.0.9
 cell基类添加父类实现强制调用宏、断言中给出未能加载的cell类名
 
 version 1.1.0
 改变cell划线机制，改为系统分割线，添加分割线归0方法
 添加自动行高计算并缓存
 cell添加xib支持
 修复选择模式选中后关闭再次开启选择同一个无法选中bug
 更换去除选择背景方式，解决与选择模式的冲突
 映射所有代理
 
 version 1.1.1
 添加自适应模式最小行高限制及最大行高设置
 添加数据源的容错机制，但这并不是你故意写错的理由=。=
 添加屏幕判断，当位置方向时，默认返回竖屏
 额外补充动画代理、支持CAAnimation及DWAnimation
 
 version 1.1.2
 展示动画逻辑修改，DWAnimation动画展示方法替换
 
 */

#import <UIKit/UIKit.h>

#pragma mark --- tableView 代理映射 ---
@class DWTableViewHelper;
@protocol DWTableViewHelperDelegate <NSObject>

@optional

///展示定制
-(void)dw_TableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
-(void)dw_TableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
-(void)dw_TableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);
-(void)dw_TableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
-(void)dw_TableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);

///高度定制
-(CGFloat)dw_TableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)dw_TableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(CGFloat)dw_TableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

///组头、组尾视图
-(UIView *)dw_TableView:(__kindof UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(UIView *)dw_TableView:(__kindof UITableView *)tableView viewForFooterInSection:(NSInteger)section;

///辅助视图
-(void)dw_TableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

///选中高亮
-(BOOL)dw_TableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath;

///选中
-(NSIndexPath *)dw_TableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *)dw_TableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(__kindof UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

///编辑
-(UITableViewCellEditingStyle)dw_TableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSString *)dw_TableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSArray<UITableViewRowAction *> *)dw_TableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)dw_TableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;///grouped 模式下有效，返回移动时是否缩进
-(void)dw_TableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *)dw_TableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;///移动时可通过源位置和目标位置判断应该到达的位置，通常情况下无需实现或返回proposedDestinationIndexPath即为不做特殊处理
-(BOOL)dw_TableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)dw_TableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

///缩进
-(NSInteger)dw_TableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath;///返回cell缩进级别。cell缩进级别不同时可调用此代理

///Copy/Paste 长按显示菜单栏，三个代理需同时实现
-(BOOL)dw_TableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)dw_TableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
-(void)dw_TableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;

///焦点 控制焦点的移动，可用于遥控器相关开发
-(BOOL)dw_TableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0);
-(BOOL)dw_TableView:(UITableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context NS_AVAILABLE_IOS(9_0);
-(void)dw_TableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator NS_AVAILABLE_IOS(9_0);
-(NSIndexPath *)dw_IndexPathForPreferredFocusedViewInTableView:(UITableView *)tableView NS_AVAILABLE_IOS(9_0);

///数据源
-(NSInteger)dw_TableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)dw_TableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)dw_NumberOfSectionsInTableView:(UITableView *)tableView;
-(NSString *)dw_TableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
-(NSString *)dw_TableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
-(NSArray<NSString *> *)dw_SectionIndexTitlesForTableView:(UITableView *)tableView;
- (NSInteger)dw_TableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
-(void)dw_TableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)dw_TableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

///预加载
-(void)dw_TableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
-(void)dw_TableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

///滑动
-(void)dw_ScrollViewDidScroll:(UIScrollView *)scrollView;
-(void)dw_ScrollViewDidZoom:(UIScrollView *)scrollView;
-(void)dw_ScrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)dw_ScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
-(void)dw_ScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
-(void)dw_ScrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
-(void)dw_ScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
-(void)dw_ScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
-(UIView *)dw_ViewForZoomingInScrollView:(UIScrollView *)scrollView;
-(void)dw_ScrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view;
-(void)dw_ScrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;
-(BOOL)dw_ScrollViewShouldScrollToTop:(UIScrollView *)scrollView;

///动画 支持返回CAAniamion对象、DWAnimation对象
-(BOOL)dw_TableView:(UITableView *)tableView shouldAnimationWithCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
-(id)dw_TableView:(UITableView *)tableView showAnimationWithCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
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

///是否使用自使用行高
/**
 优先级最低，计算一次并缓存
 */
@property (nonatomic ,assign) BOOL useAutoRowHeight;

///最小自动行高
@property (nonatomic ,assign) CGFloat minAutoRowHeight;

///最大自动行高
@property (nonatomic ,assign) CGFloat maxAutoRowHeight;

///cell展示动画
@property (nonatomic ,strong) id cellShowAnimation;

///实例化方法
-(instancetype)initWithTabV:(__kindof UITableView *)tabV dataSource:(NSArray *)dataSource;

///取出对应indexPath对应的数据模型（具有容错机制）
-(DWTableViewHelperModel *)modelFromIndexPath:(NSIndexPath *)indexPath;

///让分割线归零
-(void)setTheSeperatorToZero;

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

///自动计算的行高
/**
 会根据横竖屏进行切换
 */
@property (nonatomic ,assign) CGFloat autoCalRowHeight;

///是否从xib文件中加载cell，默认为NO
@property (nonatomic ,assign) BOOL loadCellFromNib;

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
-(void)setupUI NS_REQUIRES_SUPER;

///设置子视图约束
-(void)setupConstraints NS_REQUIRES_SUPER;

///设置数据模型
-(void)setModel:(__kindof DWTableViewHelperModel *)model NS_REQUIRES_SUPER;
@end
