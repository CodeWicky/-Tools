//
//  UITableView+DWTableViewUtils.h
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DWTableViewUtils)
///刷新列表并获取刷新完成回调
-(void)reloadDataWithCompletion:(void(^)())completion;
@end
