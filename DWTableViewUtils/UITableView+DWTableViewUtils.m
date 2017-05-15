//
//  UITableView+DWTableViewUtils.m
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "UITableView+DWTableViewUtils.h"
#import <objc/runtime.h>

@implementation UITableView (DWTableViewUtils)
-(void)reloadDataWithCompletion:(void(^)())completion
{
    if (!completion) {
        [self reloadData];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)showPlaceHolderView
{
    if (self.placeHolderView && !self.placeHolderView.superview) {
        [self addSubview:self.placeHolderView];
    }
}

-(void)hidePlaceHolderView
{
    if (self.placeHolderView && self.placeHolderView.superview) {
        [self.placeHolderView removeFromSuperview];
    }
}

-(void)reloadDataAndHandlePlaceHolderView
{
    __weak typeof(self)weakSelf = self;
    [self reloadDataWithCompletion:^{
        if ([weakSelf calculateHasData]) {
            [weakSelf hidePlaceHolderView];
        } else {
            [weakSelf showPlaceHolderView];
        }
    }];
}

-(BOOL)calculateHasData
{
    return [self dw_TotalItems] > 0 ? YES : NO;
}

-(void)setPlaceHolderView:(UIView *)placeHolderView
{
    objc_setAssociatedObject(self, @selector(placeHolderView), placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView *)placeHolderView
{
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation UITableView (DWTableViewIndexPathUtils)

-(NSInteger)dw_DistanceBetweenIndexPathA:(NSIndexPath *)idxPA indexPathB:(NSIndexPath *)idxPB {
    if (self.dataSource == nil) {
        NSAssert(NO, @"you dataSource is nil so we can't calculate the distance.");
        return -1;
    }
    if (![self dw_IsValidIndexPath:idxPA] || ![self dw_IsValidIndexPath:idxPB]) {
        NSAssert(NO, @"the indexPath you sent is not valid.you should check them.");
        return -1;
    }
    if ([idxPA isEqual:idxPB]) {
        return 0;
    }
    NSInteger sectionDelta = idxPB.section - idxPA.section;
    if (sectionDelta > 0) {
        return [self calculateDistanceWithLessSectionIdxP:idxPA greaterSectionIdxP:idxPB];
    } else if (sectionDelta < 0) {
        return [self calculateDistanceWithLessSectionIdxP:idxPB greaterSectionIdxP:idxPA];
    } else {
        return labs(idxPA.row - idxPB.row);
    }
}

-(BOOL)dw_IsValidIndexPath:(NSIndexPath *)idxP {
    if (self.dataSource == nil) {
        NSAssert(NO, @"you dataSource is nil so we can't calculate the distance.");
        return NO;
    }
    if (idxP.section >= self.numberOfSections) {
        return NO;
    }
    if (idxP.row >= [self numberOfRowsInSection:idxP.section]) {
        return NO;
    }
    return YES;
}

-(NSUInteger)calculateDistanceWithLessSectionIdxP:(NSIndexPath *)idxPA greaterSectionIdxP:(NSIndexPath *)idxPB {
    NSUInteger distance = 0;
    NSInteger row = idxPA.row + 1;
    NSInteger section = idxPA.section;
    while (section < idxPB.section) {
        distance += ([self numberOfRowsInSection:section]) - row;
        section ++;
        row = 0;
    }
    distance += (idxPB.row + 1);
    return distance;
}

-(NSUInteger)dw_TotalItems {
    NSInteger sections = self.numberOfSections;
    NSInteger itemsCount = 0;
    for (int i = 0; i < sections; i++) {
        itemsCount += [self numberOfRowsInSection:i];
    }
    return itemsCount;
}

-(NSArray <NSIndexPath *>*)dw_IndexPathsAroundIndexPath:(NSIndexPath *)idxP nextOrPreivious:(BOOL)isNext count:(NSUInteger)count step:(NSInteger)step {
    
    if (count == 0) {
        return nil;
    }
    
    if (step > [self dw_TotalItems]) {
        return nil;
    }
    
    if (step < 1) {
        step = 1;
    }
    
    NSInteger section = idxP.section;
    NSInteger row = idxP.row;
    section = section < self.numberOfSections ? section :self.numberOfSections;
    row = row <= [self numberOfRowsInSection:section] ? row :[self numberOfRowsInSection:section];
    
    NSInteger fator = isNext ? 1 : -1;
    
    NSMutableArray * arr = [NSMutableArray array];
    do {
        row += step * fator;
        if (row >= 0 && row < [self numberOfRowsInSection:section]) {
            [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        } else {
        HandleSection:
            section += fator;
            if (section < 0 || section >= self.numberOfSections) {
                break;
            } else {
                if (row < 0) {
                    row += [self numberOfRowsInSection:section];
                    if (row < 0) {
                        goto HandleSection;
                    } else {
                        [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                } else {
                    row -= [self numberOfRowsInSection:section - 1];
                    if (row >= [self numberOfRowsInSection:section]) {
                        goto HandleSection;
                    } else {
                        [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                }
            }
        }
    } while (arr.count < count);
    return arr.copy;
}
@end
