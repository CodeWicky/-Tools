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

@interface DWTableViewHelper ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL hasPlaceHolderView;
}
@property (nonatomic ,strong) UITableView * tabV;

@end

@implementation DWTableViewHelper
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
        _separatorMargin = 0;
        _rowHeight = -1;
    }
    return self;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView numberOfRowsInSection:section];
    }
    return self.dataSource.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (DWRespond) {
        return [DWDelegate dw_NumberOfSectionsInTableView:tableView];
    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView cellForRowAtIndexPath:indexPath];
    }
    DWTableViewHelperModel * model = self.dataSource[indexPath.row];
    Class cellClass = NSClassFromString(model.cellClassStr);
    __kindof DWTableViewHelperCell * cell = [tableView dequeueReusableCellWithIdentifier:model.cellID];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:model.cellID];
    }
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    if (self.dataSource[indexPath.row].cellRowHeight >= 0) {
        return self.dataSource[indexPath.row].cellRowHeight;
    }
    if (self.rowHeight >= 0) {
        return self.rowHeight;
    }
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

-(void)setDataSource:(NSArray<DWTableViewHelperModel *> *)dataSource
{
    _dataSource = dataSource;
    if (self.placeHolderView) {
        handlePlaceHolderView(self.placeHolderView,self.tabV, self.dataSource, &hasPlaceHolderView);
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
        handlePlaceHolderView(_placeHolderView, self.tabV, self.dataSource, &hasPlaceHolderView);
    }
}

static inline void handlePlaceHolderView(UIView * placeHolderView,UITableView * tabV,NSArray * dataSource,BOOL * hasPlaceHolderView){
    if (dataSource.count && *hasPlaceHolderView) {
        [placeHolderView removeFromSuperview];
        *hasPlaceHolderView = NO;
    }
    else if (!dataSource.count && !*hasPlaceHolderView)
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
@end
@implementation DWTableViewHelperModel
-(instancetype)init{
    self = [super init];
    if (self) {
        _cellRowHeight = -1;
        _cellID = [NSString stringWithFormat:@"%@DefaultCellID",NSStringFromClass([self class])];
    }
    return self;
}
@end
@implementation DWTableViewHelperCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

-(void)setupUI
{
    
}

-(void)setupConstraints
{
    
}

-(void)setModel:(__kindof DWTableViewHelperModel *)model
{
    _model = model;
}

@end

