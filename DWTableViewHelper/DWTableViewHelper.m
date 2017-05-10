//
//  DWTableViewHelper.m
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/13.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWTableViewHelper.h"
#import <objc/runtime.h>

#define SeperatorColor [UIColor lightGrayColor]

#define DWRespondTo(arr) \
SEL selec = DWTransSEL(_cmd,@"dw_",0);\
if (self.helperDelegate && [self.helperDelegate respondsToSelector:selec]) {\
id target = self.helperDelegate;\
NSMethodSignature  *signature = [[target class] instanceMethodSignatureForSelector:selec];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
invocation.target = target;\
invocation.selector = selec;\
__block int i = 2;\
[arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {\
[invocation setArgument:&obj atIndex:i];\
i++;\
}];\
[invocation invoke];\
return;\
}\


#define DWRespond \
({\
SEL selec = DWTransSEL(_cmd,@"dw_",0);\
(self.helperDelegate && [self.helperDelegate respondsToSelector:selec]);\
})


#define DWUpperFirstChar(str) \
({\
NSString * strT = [str substringToIndex:1];\
strT = strT.uppercaseString;\
strT = [NSString stringWithFormat:@"%@%@",strT,[str substringFromIndex:1]];\
strT;})


#define DWTransSEL(target,paraStr,index) \
({\
NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"[:]" options:0 error:0];\
NSString * targetStr = NSStringFromSelector(target);\
NSArray * arr = [regex matchesInString:targetStr options:0 range:NSMakeRange(0, targetStr.length)];\
if (arr.count == 0) {\
targetStr = [targetStr stringByAppendingString:DWUpperFirstChar(paraStr)];\
}\
else\
{\
if (index == 0) {\
targetStr = [paraStr stringByAppendingString:DWUpperFirstChar(targetStr)];\
} else if (index >= arr.count) {\
targetStr = [targetStr stringByAppendingString:paraStr];\
} else {\
NSRange range = [[arr[index - 1] valueForKey:@"range"] rangeValue];\
range = NSMakeRange(range.location + 1, 0);\
targetStr = [targetStr stringByReplacingCharactersInRange:range withString:paraStr];\
}\
}\
NSSelectorFromString(targetStr);\
})


#define DWDelegate self.helperDelegate



static UIImage * ImageNull = nil;

@interface DWTableViewHelper ()<UITableViewDelegate,UITableViewDataSource,UITableViewDataSourcePrefetching>
{
    BOOL hasPlaceHolderView;
}

@property (nonatomic ,strong) UITableView * tabV;

@property (nonatomic ,strong) NSIndexPath * lastSelected;

@property (nonatomic ,strong) NSMutableDictionary * dic4CalCell;

@end

@implementation DWTableViewHelper
static DWTableViewHelperModel * PlaceHolderCellModelAvoidCrashing = nil;

@synthesize cellClassStr,cellID,cellRowHeight,cellEditSelectedIcon,cellEditUnselectedIcon;

-(instancetype)initWithTabV:(__kindof UITableView *)tabV dataSource:(NSArray *)dataSource
{
    self = [super init];
    if (self) {
        _tabV = tabV;
        tabV.delegate = self;
        tabV.dataSource = self;
        if (UIDevice.currentDevice.systemVersion.floatValue >= 10.0) {
            tabV.prefetchDataSource = self;
        }
        _dataSource = dataSource;
        _multiSection = NO;
        self.cellRowHeight = -1;
        _selectEnable = tabV.editing;
        _minAutoRowHeight = -1;
        _maxAutoRowHeight = -1;
    }
    return self;
}

-(void)setTheSeperatorToZero {
    [self.tabV setSeparatorInset:UIEdgeInsetsZero];
}

-(DWTableViewHelperModel *)modelFromIndexPath:(NSIndexPath *)indexPath {
    id obj = nil;
    if (self.multiSection) {
        obj = self.dataSource[indexPath.section];
        if (![obj isKindOfClass:[NSArray class]]) {
            NSAssert(NO, @"you set to use multiSection but the obj in section %ld of dataSource is not kind of NSArray but %@",indexPath.section,NSStringFromClass([obj class]));
            if ([obj isKindOfClass:[DWTableViewHelperModel class]]) {
                return obj;
            }
            return nil;
        }
        obj = self.dataSource[indexPath.section][indexPath.row];
        if (![obj isKindOfClass:[DWTableViewHelperModel class]]) {
            NSAssert(NO, @"you set to use multiSection but the obj in section %ld row %ld of dataSource is not kind of DWTableViewHelperModel but %@",indexPath.section,indexPath.row,NSStringFromClass([obj class]));
            obj = PlaceHolderCellModelAvoidCrashingGetter();
        }
    }
    else
    {
        obj = self.dataSource[indexPath.row];
        if (![obj isKindOfClass:[DWTableViewHelperModel class]]) {
            NSAssert(NO, @"you set to not use multiSection but the obj in row %ld of dataSource is not kind of DWTableViewHelperModel but %@",indexPath.row,NSStringFromClass([obj class]));
            if ([obj isKindOfClass:[NSArray class]] && [obj count] > 0 && [[obj firstObject] isKindOfClass:[DWTableViewHelperModel class]]) {
                obj = [obj firstObject];
            } else {
                obj = PlaceHolderCellModelAvoidCrashingGetter();
            }
        }
    }
    return obj;
}

-(void)reloadDataWithCompletion:(void (^)())completion
{
    if (!completion) {
        [self.tabV reloadData];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabV reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)reloadDataAndHandlePlaceHolderView
{
    BOOL haveData = [self caculateHaveData];
    __weak typeof(self)weakSelf = self;
    [self reloadDataWithCompletion:^{
        handlePlaceHolderView(weakSelf.placeHolderView, weakSelf.tabV, !haveData, &hasPlaceHolderView);
    }];
}

-(void)showPlaceHolderView
{
    handlePlaceHolderView(self.placeHolderView, self.tabV, YES, &hasPlaceHolderView);
}

-(void)hidePlaceHolderView
{
    handlePlaceHolderView(self.placeHolderView, self.tabV, NO, &hasPlaceHolderView);
}

-(void)setAllSelect:(BOOL)select
{
    NSUInteger count = [self numberOfSectionsInTableView:self.tabV];
    if (select) {
        for (int i = 0; i < count; i++) {
            [self setSection:i allSelect:select];
        }
    }
    else
    {
        [self.tabV reloadData];
    }
}

-(void)setSection:(NSUInteger)section allSelect:(BOOL)select
{
    NSUInteger count = [self numberOfSectionsInTableView:self.tabV];
    if (section >= count) {
        return;
    }
    NSUInteger rows = [self tableView:self.tabV numberOfRowsInSection:section];
    if (select) {
        for (int i = 0; i < rows; i++) {
            [self.tabV selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else
    {
        for (int i = 0; i < rows; i++) {
            [self.tabV deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO];
        }
    }
}

-(void)invertSelectAll
{
    NSUInteger count = [self numberOfSectionsInTableView:self.tabV];
    for (int i = 0; i < count; i++) {
        [self invertSelectSection:i];
    }
}

-(void)invertSelectSection:(NSUInteger)section
{
    NSUInteger count = [self numberOfSectionsInTableView:self.tabV];
    if (section >= count) {
        return;
    }
    NSUInteger rows = [self tableView:self.tabV numberOfRowsInSection:section];
    NSArray * arr = filterArray(self.selectedRows, ^BOOL(NSIndexPath * obj, NSUInteger idx, NSUInteger count, BOOL *stop) {
        return obj.section == section;
    });
    for (int i = 0; i < rows; i++) {
        __block BOOL select = NO;
        [arr enumerateObjectsUsingBlock:^(NSIndexPath * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.row == i) {
                select = YES;
                *stop = YES;
            }
        }];
        if (select) {
            [self.tabV deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO];
        }
        else
        {
            [self.tabV selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark --- delegate Map Start ---
///display
-(void)tableView:(UITableView *)tableView willDisplayCell:(DWTableViewHelperCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellEditSelectedIcon && cell.model.cellEditSelectedIcon == ImageNull) {
        cell.model.cellEditSelectedIcon = self.cellEditSelectedIcon;
    }
    if (self.cellEditUnselectedIcon && cell.model.cellEditUnselectedIcon == ImageNull) {
        cell.model.cellEditUnselectedIcon = self.cellEditUnselectedIcon;
    }
    
    [self handleCellShowAnimationWithTableView:tableView cell:cell indexPath:indexPath];
    
    DWRespondTo(DWParas(tableView,cell,indexPath,nil));
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    DWRespondTo(DWParas(tableView,cell,indexPath,nil));
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

///height
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView heightForRowAtIndexPath:indexPath];
    }
    DWTableViewHelperModel * model = [self modelFromIndexPath:indexPath];
    if (model.cellRowHeight >= 0) {
        return model.cellRowHeight;
    }
    if (self.cellRowHeight >= 0) {
        return self.cellRowHeight;
    }
    if (self.useAutoRowHeight) {//返回放回自动计算的行高
        return [self autoCalculateRowHeightWithModel:model];
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView heightForHeaderInSection:section];
    }
    if (self.helperDelegate && [self.helperDelegate respondsToSelector:@selector(dw_TableView:viewForHeaderInSection:)]) {
        return [self.helperDelegate dw_TableView:tableView viewForHeaderInSection:section].bounds.size.height;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView heightForFooterInSection:section];
    }
    if (self.helperDelegate && [self.helperDelegate respondsToSelector:@selector(dw_TableView:heightForFooterInSection:)]) {
        return [self.helperDelegate dw_TableView:tableView viewForFooterInSection:section].bounds.size.height;
    }
    return 0.01;
}

///sectionHeader、sectionFooter
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

///accessory
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

///highlight
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

///选中
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectEnable) {
        if (!self.multiSelect && self.lastSelected) {
            [tableView deselectRowAtIndexPath:self.lastSelected animated:YES];
        }
        self.lastSelected = indexPath;
        return;
    }
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectEnable) {
        self.lastSelected = nil;
        return;
    }
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

///editing
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    if (self.selectEnable) {
        return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return @"Delete";
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    return YES;
}

///indentation
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    return 0;
}

///copy / paste
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    return NO;
}
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

///focus
- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView canFocusRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView shouldUpdateFocusInContext:context];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    DWRespondTo(DWParas(tableView,context,coordinator,nil));
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(UITableView *)tableView {
    if (DWRespond) {
        return [DWDelegate dw_IndexPathForPreferredFocusedViewInTableView:tableView];
    }
    return nil;
}

///dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView numberOfRowsInSection:section];
    }
    if (self.multiSection) {
        id obj = self.dataSource[section];
        if (![obj isKindOfClass:[NSArray class]]) {
            NSAssert(NO, @"you set to use multiSection but the obj in section %ld of dataSource is not kind of NSArray but %@",section,NSStringFromClass([obj class]));
            if ([obj isKindOfClass:[DWTableViewHelperModel class]]) {
                return 1;
            }
            return 0;
        }
        return [[self.dataSource objectAtIndex:section] count];
    }
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView cellForRowAtIndexPath:indexPath];
    }
    DWTableViewHelperModel * model = [self modelFromIndexPath:indexPath];
    __kindof DWTableViewHelperCell * cell = [self createCellFromModel:model useReuse:YES];
    cell.model = model;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (DWRespond) {
        return [DWDelegate dw_NumberOfSectionsInTableView:tableView];
    }
    if (self.multiSection) {
        return self.dataSource.count;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView titleForFooterInSection:section];
    }
    return nil;
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (DWRespond) {
        return [DWDelegate dw_SectionIndexTitlesForTableView:tableView];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
    return index;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    DWRespondTo(DWParas(tableView,sourceIndexPath,destinationIndexPath,nil));
}

///prefetch
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    DWRespondTo(DWParas(tableView,indexPaths,nil));
}

- (void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    DWRespondTo(DWParas(tableView,indexPaths,nil));
}

///scroll
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (DWRespond) {
        [DWDelegate dw_ScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (DWRespond) {
        [DWDelegate dw_ScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (DWRespond) {
        return [DWDelegate dw_ViewForZoomingInScrollView:scrollView];
    }
    return nil;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (DWRespond) {
        return [DWDelegate dw_ScrollViewWillBeginZooming:scrollView withView:view];
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (DWRespond) {
        [DWDelegate dw_ScrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if (DWRespond) {
        return [DWDelegate dw_ScrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

#pragma mark --- delegate Map End ---

#pragma mark --- tool Method ---
-(BOOL)caculateHaveData {
    NSInteger count = 0;
    if (self.multiSection) {
        NSInteger sections = [self numberOfSectionsInTableView:self.tabV];
        for (int i = 0; i < sections; i++) {
            count += [self rowsOfSection:i];
        }
    } else {
        count = [self rowsOfSection:0];
    }
    return count > 0 ? YES : NO;
}

-(NSInteger)rowsOfSection:(NSUInteger)section
{
    return [self tableView:self.tabV numberOfRowsInSection:section];
}

-(CGFloat)autoCalculateRowHeightWithModel:(__kindof DWTableViewHelperModel *)model {
    if (model.autoCalRowHeight >= 0) {
        return model.autoCalRowHeight;
    }
    __kindof DWTableViewHelperCell * cell = [self createCellFromModel:model useReuse:NO];
    cell.model = model;
    cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat calRowHeight = [self calculateCellHeightWithCell:cell];
    if (self.maxAutoRowHeight > 0 || self.minAutoRowHeight > 0) {
        if (self.maxAutoRowHeight > 0 && self.minAutoRowHeight > 0 && self.maxAutoRowHeight < self.minAutoRowHeight) {
            NSAssert(NO, @"wrong autoRowHeight limit with maximum %.2f and minimum %.2f",self.maxAutoRowHeight,self.minAutoRowHeight);
        } else {
            if ((self.minAutoRowHeight > 0) && calRowHeight < self.minAutoRowHeight) {
                calRowHeight = self.minAutoRowHeight;
            } else if ((self.maxAutoRowHeight > 0) && (self.maxAutoRowHeight < calRowHeight)) {
                calRowHeight = self.maxAutoRowHeight;
            }
        }
    }
    if (calRowHeight >= 0) {
        model.autoCalRowHeight = calRowHeight;
    }
    return model.autoCalRowHeight;
}

///根据cell计算cell的高度（代码源自FDTemplateLayoutCell）
-(CGFloat)calculateCellHeightWithCell:(UITableViewCell *)cell
{
    CGFloat width = self.tabV.bounds.size.width;
    if (width <= 0) {
        return -1;
    }
    //根据辅助视图校正width
    if (cell.accessoryView) {
        width -= cell.accessoryView.bounds.size.width + 16;
    }
    else
    {
        static const CGFloat accessoryWidth[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        width -= accessoryWidth[cell.accessoryType];
    }
    CGFloat height = 0;
    if (width > 0) {//如果不是非自适应模式则添加约束后计算约束后高度
        NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
        
        // iOS10.2以后，cell的contentView会额外添加一条宽度为0的约束。通过给他添加上下左右的约束来是此约束失效
        static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });
        
        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThen10_2) {
            ///为了避免冲突，修改优先级为optional
             widthConstraint.priority = UILayoutPriorityRequired - 1;
            
            ///添加4个约束
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
            [cell addConstraints:edgeConstraints];
        }
        
        [cell.contentView addConstraint: widthConstraint];
        
        ///根据约束计算高度
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        //移除额外添加的约束
        [cell.contentView removeConstraint: widthConstraint];
        if (isSystemVersionEqualOrGreaterThen10_2) {
            [cell removeConstraints:edgeConstraints];
        }
    }
    if (height == 0) {//如果约束错误可能导致计算结果为零，则以自适应模式再次计算
        height = [cell sizeThatFits:CGSizeMake(width, 0)].height;
    }
    if (height == 0) {//如果计算仍然为0，则给出默认高度
        height = 44;
    }
    if (self.tabV.separatorStyle != UITableViewCellSeparatorStyleNone) {//如果不为无分割线模式则添加分割线高度
        height += 1.0 /[UIScreen mainScreen].scale;
    }
    return height;
}

-(__kindof DWTableViewHelperCell *)createCellFromModel:(DWTableViewHelperModel *)model useReuse:(BOOL)useReuse {
    NSString * cellIDTemp;
    NSString * aCellClassStr;
    if (model.cellClassStr.length && model.cellID.length) {
        cellIDTemp = model.cellID;
        aCellClassStr = model.cellClassStr;
    } else if (self.cellClassStr.length && self.cellID.length) {
        cellIDTemp = self.cellID;
        aCellClassStr = self.cellClassStr;
    } else {
        NSAssert(NO, @"cellClassStr and cellID must be set together at least one time in DWTableViewHelperModel or DWTableViewHelper");
        return nil;
    }
    __kindof DWTableViewHelperCell * cell = nil;
    if (useReuse) {
        cell = [self.tabV dequeueReusableCellWithIdentifier:cellIDTemp];
        if (cell) {
            return cell;
        }
    } else {
        cell = self.dic4CalCell[aCellClassStr];
        if (cell) {
            return cell;
        }
    }
    
    Class cellClass = NSClassFromString(aCellClassStr);
    if (!cellClass) {
        NSAssert(NO, @"cannot load a cellClass from %@,check the cellClassStr you have set",model.cellClassStr.length?model.cellClassStr:self.cellClassStr);
        return nil;
    }
    
    if (model.loadCellFromNib) {
        cell = [[NSBundle mainBundle] loadNibNamed:aCellClassStr owner:nil options:nil].lastObject;
        if (cell && !useReuse) {
            self.dic4CalCell[aCellClassStr] = cell;
        }
        return cell;
    }
    
    cell = [[cellClass alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIDTemp];
    if (cell && !useReuse) {
        self.dic4CalCell[aCellClassStr] = cell;
    }
    return cell;
}

-(void)handleCellShowAnimationWithTableView:(UITableView *)tableView cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    ///处理动画
    BOOL needShow = YES;
    if (DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:shouldAnimationWithCell:forRowAtIndexPath:)]) {
        needShow = [DWDelegate dw_TableView:tableView shouldAnimationWithCell:cell forRowAtIndexPath:indexPath];
    }
    if (needShow) {
        id animation = nil;
        if (DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:showAnimationWithCell:forRowAtIndexPath:)]) {
            animation = [DWDelegate dw_TableView:tableView showAnimationWithCell:cell forRowAtIndexPath:indexPath];
        }
        if (!animation) {
            animation = self.cellShowAnimation;
        }
        if (animation) {
            if ([animation isKindOfClass:[CAAnimation class]]) {
                [cell.layer addAnimation:animation forKey:@"animation"];
            } else if ([animation isKindOfClass:NSClassFromString(@"DWAnimationAbstraction")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [animation performSelector:NSSelectorFromString(@"startAnimationWithContent:") withObject:cell];
#pragma clang diagnostic pop
            }
        }
    }
}

#pragma mark --- setter/getter ---
-(void)setDataSource:(NSArray<DWTableViewHelperModel *> *)dataSource
{
    _dataSource = dataSource;
    if (self.placeHolderView) {
        handlePlaceHolderView(self.placeHolderView,self.tabV, ![self caculateHaveData], &hasPlaceHolderView);
    }
}

-(void)setPlaceHolderView:(UIView *)placeHolderView
{
    if (_placeHolderView == placeHolderView) {
        return;
    }
    if (hasPlaceHolderView) {
        [_placeHolderView removeFromSuperview];
    }
    _placeHolderView = placeHolderView;
    if (_placeHolderView) {
        handlePlaceHolderView(_placeHolderView, self.tabV,![self caculateHaveData], &hasPlaceHolderView);
    }
}

-(void)setSelectEnable:(BOOL)selectEnable
{
    _selectEnable = selectEnable;
    if (!selectEnable) {
        self.lastSelected = nil;
    }
    [self.tabV setEditing:selectEnable animated:YES];
}

-(void)setMultiSelect:(BOOL)multiSelect
{
    _multiSelect = multiSelect;
    if (!multiSelect) {
        if (self.selectedRows.count > 1) {
            NSIndexPath * idxP = self.selectedRows.firstObject;
            [self.tabV reloadData];
            if (self.lastSelected) {
                [self.tabV selectRowAtIndexPath:self.lastSelected animated:NO scrollPosition:UITableViewScrollPositionNone];
            } else {
                self.lastSelected = idxP;
                [self.tabV selectRowAtIndexPath:idxP animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

-(NSArray *)selectedRows
{
    return self.tabV.indexPathsForSelectedRows.copy;
}

-(NSMutableDictionary *)dic4CalCell
{
    if (!_dic4CalCell) {
        _dic4CalCell = [NSMutableDictionary dictionary];
    }
    return _dic4CalCell;
}

#pragma mark --- inline Method ---
static inline void handlePlaceHolderView(UIView * placeHolderView,UITableView * tabV,BOOL toSetHave,BOOL * hasPlaceHolderView){
    if (!toSetHave && *hasPlaceHolderView) {
        [placeHolderView removeFromSuperview];
        *hasPlaceHolderView = NO;
    }
    else if (toSetHave && !*hasPlaceHolderView)
    {
        [tabV addSubview:placeHolderView];
        *hasPlaceHolderView = YES;
    }
}

static inline NSArray * DWParas(NSObject * aObj,...){
    NSMutableArray* keys = [NSMutableArray array];
    va_list argList;
    if(aObj){
        [keys addObject:aObj];
        va_start(argList, aObj);
        id arg;
        while ((arg = va_arg(argList, id))) {
            [keys addObject:arg];
        }
    }
    va_end(argList);
    return keys.copy;
};

static inline NSArray * filterArray(NSArray * array,BOOL(^block)(id obj, NSUInteger idx,NSUInteger count,BOOL * stop))
{
    NSMutableArray * arr = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj,idx,arr.count,stop)) {
            [arr addObject:obj];
        }
    }];
    return arr.copy;
}

static inline DWTableViewHelperModel * PlaceHolderCellModelAvoidCrashingGetter () {
    if (PlaceHolderCellModelAvoidCrashing == nil) {
        PlaceHolderCellModelAvoidCrashing = [DWTableViewHelperModel new];
        PlaceHolderCellModelAvoidCrashing.cellRowHeight = 0;
        PlaceHolderCellModelAvoidCrashing.cellClassStr = NSStringFromClass([DWTableViewHelperCell class]);
        PlaceHolderCellModelAvoidCrashing.cellID = @"PlaceHolderCellAvoidCrashing";
        
    }
    return PlaceHolderCellModelAvoidCrashing;
}

@end


@interface DWTableViewHelperModel ()

///计算的竖屏行高
@property (nonatomic ,assign) CGFloat calRowHeightV;

///计算的横屏行高
@property (nonatomic ,assign) CGFloat calRowHeightH;

@end

@implementation DWTableViewHelperModel

@synthesize cellClassStr,cellID,cellRowHeight,cellEditSelectedIcon,cellEditUnselectedIcon;

-(instancetype)init{
    self = [super init];
    if (self) {
        self.cellRowHeight = -1;
        if (!ImageNull) {
            ImageNull = [UIImage new];
        }
        NSString * cellClass = NSStringFromClass([self class]);
        NSArray * arr = [cellClass componentsSeparatedByString:@"Model"];
        if (arr.count) {
            cellClass = [NSString stringWithFormat:@"%@Cell",arr.firstObject];
        } else {
            cellClass = @"DWTableViewHelperCell";
        }
        self.cellClassStr = cellClass;
        self.cellID = [NSString stringWithFormat:@"%@DefaultCellID",cellClass];
        self.cellEditSelectedIcon = ImageNull;
        self.cellEditUnselectedIcon = ImageNull;
        self.calRowHeightH = -1;
        self.calRowHeightV = -1;
    }
    return self;
}

-(CGFloat)autoCalRowHeight {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationUnknown) {
        return self.calRowHeightV;
    } else {
        return self.calRowHeightH;
    }
}

-(void)setAutoCalRowHeight:(CGFloat)autoCalRowHeight {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationUnknown) {
        self.calRowHeightV = autoCalRowHeight;
    } else {
        self.calRowHeightH = autoCalRowHeight;
    }
}

@end


@implementation DWTableViewHelperCell
static UIImage * defaultSelectIcon = nil;
static UIImage * defaultUnselectIcon = nil;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
    [self setupConstraints];
}

-(void)layoutSubviews
{
    BOOL toSetSelectIcon = self.model.cellEditSelectedIcon != ImageNull && self.model.cellEditSelectedIcon != nil;
    BOOL toSetUnselectIcon = self.model.cellEditUnselectedIcon != ImageNull && self.model.cellEditUnselectedIcon != nil;
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *v in control.subviews)
            {
                if ([v isKindOfClass: [UIImageView class]]) {
                    UIImageView *img = (UIImageView *)v;
                    if (self.selected) {
                        if (toSetSelectIcon) {
                            if (!defaultSelectIcon) {
                                defaultSelectIcon = img.image;
                            }
                            img.image = self.model.cellEditSelectedIcon;
                        } else if (defaultSelectIcon) {
                            img.image = defaultSelectIcon;
                        }
                    } else {
                        if (toSetUnselectIcon) {
                            if (!defaultUnselectIcon) {
                                defaultUnselectIcon = img.image;
                            }
                            img.image = self.model.cellEditUnselectedIcon;
                        } else if (defaultUnselectIcon) {
                            img.image = defaultUnselectIcon;
                        }
                    }
                }
            }
        }
    }
    [super layoutSubviews];
}

///适配第一次图片为空的情况
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (self.selectionStyle == UITableViewCellSelectionStyleNone) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    BOOL toSetUnselectIcon = self.model.cellEditUnselectedIcon != ImageNull && self.model.cellEditUnselectedIcon != nil;
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *v in control.subviews)
            {
                if ([v isKindOfClass: [UIImageView class]]) {
                    UIImageView *img=(UIImageView *)v;
                    if (!self.selected) {
                        if (toSetUnselectIcon) {
                            if (!defaultUnselectIcon) {
                                defaultUnselectIcon = img.image;
                            }
                            img.image = self.model.cellEditUnselectedIcon;
                        } else if (defaultUnselectIcon) {
                            img.image = defaultUnselectIcon;
                        }
                    }
                }
            }
        }
    }
}

-(void)setupUI {
    ///去除选择背景
    self.multipleSelectionBackgroundView = [UIView new];
    self.selectedBackgroundView = [UIView new];
}

-(void)setupConstraints {
    
}

-(void)setModel:(__kindof DWTableViewHelperModel *)model
{
    _model = model;
}

@end

