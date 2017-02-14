//
//  DWTableViewHelper.m
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/13.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWTableViewHelper.h"

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

@interface DWTableViewHelper ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL hasPlaceHolderView;
}

@property (nonatomic ,strong) UITableView * tabV;

@property (nonatomic ,strong) NSIndexPath * lastSelected;

@end

@implementation DWTableViewHelper

@synthesize cellClassStr,cellID,cellRowHeight,cellEditSelectedIcon,cellEditUnselectedIcon;

-(instancetype)initWithTabV:(__kindof UITableView *)tabV dataSource:(NSArray *)dataSource
{
    self = [super init];
    if (self) {
        _tabV = tabV;
        tabV.delegate = self;
        tabV.dataSource = self;
        tabV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _dataSource = dataSource;
        _needSeparator = YES;
        _multiSection = NO;
        _separatorMargin = 0;
        self.cellRowHeight = -1;
        _selectEnable = tabV.editing;
    }
    return self;
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView numberOfRowsInSection:section];
    }
    if (self.multiSection) {
        return [[self.dataSource objectAtIndex:section] count];
    }
    return self.dataSource.count;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView cellForRowAtIndexPath:indexPath];
    }
    DWTableViewHelperModel * model = modelFromIndexPath(indexPath, self);
    Class cellClass;
    NSString * cellIDTemp;
    if (model.cellClassStr.length && model.cellID.length) {
        cellIDTemp = model.cellID;
        cellClass = NSClassFromString(model.cellClassStr);
    } else if (self.cellClassStr.length && self.cellID.length) {
        cellIDTemp = self.cellID;
        cellClass = NSClassFromString(self.cellClassStr);
    } else {
        NSAssert(NO, @"cellClassStr and cellID must be set together at least one time in DWTableViewHelperModel or DWTableViewHelper");
        return nil;
    }
    if (!cellClass) {
        NSAssert(NO, @"cannot load a cellClass from cellClassStr,check the cellClassStr you have set");
        return nil;
    }
    __kindof DWTableViewHelperCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIDTemp];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIDTemp];
    }
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(DWTableViewHelperCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellEditSelectedIcon && cell.model.cellEditSelectedIcon == ImageNull) {
        cell.model.cellEditSelectedIcon = self.cellEditSelectedIcon;
    }
    if (self.cellEditUnselectedIcon && cell.model.cellEditUnselectedIcon == ImageNull) {
        cell.model.cellEditUnselectedIcon = self.cellEditUnselectedIcon;
    }
    DWRespondTo(MYFParas(tableView,cell,indexPath,nil));
    if (self.needSeparator) {
        NSInteger row = indexPath.row;
        CGFloat cellWidth = cell.bounds.size.width;
        UIView * backGroundView = [[UIView alloc] initWithFrame:cell.bounds];
        if (row == 0) {
            [backGroundView.layer addSublayer:createLine(cellWidth, CGPointMake(cellWidth / 2.0, 0.25), SeperatorColor)];
        }
        CGFloat width = (row == self.dataSource.count - 1) ? cellWidth : cellWidth - self.separatorMargin * 2;
        [backGroundView.layer addSublayer:createLine(width, CGPointMake(cellWidth / 2.0, cell.bounds.size.height - 0.25), SeperatorColor)];
        cell.backgroundView = backGroundView;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView heightForRowAtIndexPath:indexPath];
    }
    DWTableViewHelperModel * model = modelFromIndexPath(indexPath, self);
    if (model.cellRowHeight >= 0) {
        return model.cellRowHeight;
    }
    if (self.cellRowHeight >= 0) {
        return self.cellRowHeight;
    }
    return 44;
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
    DWRespondTo(MYFParas(tableView,indexPath,nil));
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectEnable) {
        self.lastSelected = nil;
        return;
    }
    DWRespondTo(MYFParas(tableView,indexPath,nil));
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DWRespondTo(MYFParas(scrollView,nil));
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

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

-(BOOL)caculateHaveData
{
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

-(NSArray *)selectedRows
{
    return self.tabV.indexPathsForSelectedRows.copy;
}

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

static inline CALayer * createLine(CGFloat width,CGPoint position,UIColor * color){
    CALayer * line = [CALayer layer];
    line.backgroundColor = color.CGColor;
    line.bounds = CGRectMake(0, 0, width, 0.5);
    line.position = position;
    return line;
}

static inline NSArray * MYFParas(NSObject * aObj,...){
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

static inline DWTableViewHelperModel * modelFromIndexPath(NSIndexPath * indexPath ,DWTableViewHelper * helper)
{
    DWTableViewHelperModel * model = nil;
    if (helper.multiSection) {
        model = helper.dataSource[indexPath.section][indexPath.row];
    }
    else
    {
        model = helper.dataSource[indexPath.row];
    }
    return model;
}

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
    }
    return self;
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
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
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

-(void)setupUI
{
    self.multipleSelectionBackgroundView = [UIView new];
    self.selectedBackgroundView = [UIView new];
}

-(void)setupConstraints
{
    
}

-(void)setModel:(__kindof DWTableViewHelperModel *)model
{
    _model = model;
}

@end

