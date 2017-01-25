//
//  UITableView+DWTableViewUtils.m
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "UITableView+DWTableViewUtils.h"

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
@end
