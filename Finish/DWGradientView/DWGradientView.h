//
//  DWGradientView.h
//  AccountBook
//
//  Created by Wicky on 2018/10/16.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWGradientView : UIControl

///CGColors
@property (nonatomic ,strong ,nullable) NSArray * colors;

@property (nonatomic ,strong) NSArray <NSNumber *>* locations;

@property (nonatomic ,assign) CGPoint startPoint;

@property (nonatomic ,assign) CGPoint endPoint;

@end

NS_ASSUME_NONNULL_END
