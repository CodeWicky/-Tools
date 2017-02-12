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
    NSInteger sections = [self.dataSource numberOfSectionsInTableView:self];
    NSInteger dataCounts = 0;
    for (int i = 0; i < sections; i++) {
        dataCounts += [self.dataSource tableView:self numberOfRowsInSection:i];
    }
    return dataCounts > 0 ? YES : NO;
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
